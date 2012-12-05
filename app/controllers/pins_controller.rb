require 'open-uri'
require 'json'
class PinsController < ApplicationController
  # GET /pins
  # GET /pins.json
  @@cache = { updated_at: Time.now }

  def search
    redirect_to action: "new", search: params[:search]
  end
  def index
    @@cache = {updated_at: Time.now} if !@@cache.has_key?(:updated_at) || Time.now.minus_with_coercion(@@cache[:updated_at]) > 2*60*60
    @new_pin = Pin.new
    @pins = []
    if session[:user_id]
      @pins = Pin.where("user_id = ?", session[:user_id]).sort_by(&:updated_at).reverse
      @pins.each do |pin|
        begin
          next if @@cache[pin]
          @@cache[pin] = {}
          open("http://api.wunderground.com/api/c86212bca3562794/conditions/q/#{pin.latitude},#{pin.longitude}.json") do |f|
            json_string = f.read
            parsed_json = JSON.parse(json_string)
            @@cache[pin][:location] = parsed_json['location']['city']
            @@cache[pin][:wind_mph] = parsed_json['current_observation']['wind_mph']
            @@cache[pin][:wind_dir] = parsed_json['current_observation']['wind_dir']
          end
          open("http://api.wunderground.com/api/c86212bca3562794/hourly/q/#{pin.latitude},#{pin.longitude}.json") do |f|
            json_string = f.read
            parsed_json = JSON.parse(json_string)
            @@cache[pin][:hourly] = parsed_json['hourly_forecast']
          end
          open("http://api.wunderground.com/api/c86212bca3562794/forecast10day/q/#{pin.latitude},#{pin.longitude}.json") do |f|
            json_string = f.read
            parsed_json = JSON.parse(json_string)
            @@cache[pin][:daily] = parsed_json['forecast']['simpleforecast']['forecastday']
          end
        rescue
          @pins.delete(pin)
        end
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pins }
    end
  end

  # GET /pins/1
  # GET /pins/1.json
  def show
    @pin = Pin.find(params[:id])
    @pin.touch
    if !@@cache[@pin]
      pin = @pin
      @@cache[pin] = {}
      open("http://api.wunderground.com/api/c86212bca3562794/geolookup/conditions/q/#{pin.latitude},#{pin.longitude}.json") do |f|
        json_string = f.read
        parsed_json = JSON.parse(json_string)
        @@cache[pin][:location] = parsed_json['location']['city']
        @@cache[pin][:wind_mph] = parsed_json['current_observation']['wind_mph']
        @@cache[pin][:wind_dir] = parsed_json['current_observation']['wind_dir']
      end
      open("http://api.wunderground.com/api/c86212bca3562794/hourly/q/#{pin.latitude},#{pin.longitude}.json") do |f|
        json_string = f.read
        parsed_json = JSON.parse(json_string)
        @@cache[pin][:hourly] = parsed_json['hourly_forecast']
      end
      open("http://api.wunderground.com/api/c86212bca3562794/forecast10day/q/#{pin.latitude},#{pin.longitude}.json") do |f|
        json_string = f.read
        parsed_json = JSON.parse(json_string)
        @@cache[pin][:daily] = parsed_json['forecast']['simpleforecast']['forecastday']
      end
    end
    @location = @@cache[@pin][:location]
    @wind_mph = @@cache[@pin][:wind_mph]
    @wind_dir = @@cache[@pin][:wind_dir]

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pin }
    end
  end

  def hourly
    @pin = Pin.find(params[:id])
    @location = @@cache[@pin][:location]
    @wind_mph = @@cache[@pin][:wind_mph]
    @wind_dir = @@cache[@pin][:wind_dir]
    @hourlies = @@cache[@pin][:hourly]

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pin }
    end
  end

  def daily
    @pin = Pin.find(params[:id])
    @location = @@cache[@pin][:location]
    @wind_mph = @@cache[@pin][:wind_mph]
    @wind_dir = @@cache[@pin][:wind_dir]
    @days = @@cache[@pin][:daily]

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pin }
    end
  end

  # GET /pins/new
  # GET /pins/new.json
  def new
    json_string = open("https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{URI.escape(params["search"])}&sensor=false&key=AIzaSyAuc-paMz_ShQYipaLv-7hp7Lp5RCjIalI") { |f| f.read }
    @pin = Pin.new
    @results = JSON.parse(json_string)["results"].map do |elem|
      {
        name: elem["formatted_address"],
        latitude: elem["geometry"]["location"]["lat"],
        longitude: elem["geometry"]["location"]["lng"]
      }
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pin }
    end
  end

  # POST /pins
  # POST /pins.json
  def create
    @pin = Pin.new(params[:pin])
    if @pin.name.blank?
      @pin.name = "#{@pin.latitude}, #{@pin.longitude}"
      json_string = open("http://maps.googleapis.com/maps/api/geocode/json?latlng=#{@pin.latitude},#{@pin.longitude}&sensor=true") { |f| f.read }
      results = JSON.parse(json_string)["results"]
      if results.size > 0 && ! results[0]["formatted_address"].empty?
        @pin.name = results[0]["formatted_address"]
      end
    end

    respond_to do |format|
      if @pin.save
        format.html { redirect_to @pin, notice: 'Pin was successfully created.' }
        format.json { render json: @pin, status: :created, location: @pin }
      else
        format.html { render action: "new" }
        format.json { render json: @pin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pins/1
  # DELETE /pins/1.json
  def destroy
    @pin = Pin.find(params[:id])
    @pin.destroy

    respond_to do |format|
      format.html { redirect_to pins_url }
      format.json { head :no_content }
    end
  end
end
