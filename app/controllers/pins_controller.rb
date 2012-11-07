require 'open-uri'
require 'json'
class PinsController < ApplicationController
  # GET /pins
  # GET /pins.json
  @@cache = {}
  def index
    redirect_to "/signup" unless session[:user_id]
    @pins = Pin.where("user_id = ?", session[:user_id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pins }
    end
  end

  # GET /pins/1
  # GET /pins/1.json
  def show
    @pin = Pin.find(params[:id])
    @@cache[@pin] = {}
    open("http://api.wunderground.com/api/c86212bca3562794/geolookup/conditions/q/#{@pin.latitude},#{@pin.longitude}.json") do |f|
      json_string = f.read
      parsed_json = JSON.parse(json_string)
      @@cache[@pin][:location] = parsed_json['location']['city']
      @@cache[@pin][:wind_mph] = parsed_json['current_observation']['wind_mph']
      @@cache[@pin][:wind_dir] = parsed_json['current_observation']['wind_dir']
    end
    open("http://api.wunderground.com/api/c86212bca3562794/hourly/q/#{@pin.latitude},#{@pin.longitude}.json") do |f|
      json_string = f.read
      parsed_json = JSON.parse(json_string)
      @@cache[@pin][:hourly] = parsed_json['hourly_forecast']
    end
    open("http://api.wunderground.com/api/c86212bca3562794/forecast10day/q/#{@pin.latitude},#{@pin.longitude}.json") do |f|
      json_string = f.read
      parsed_json = JSON.parse(json_string)
      @@cache[@pin][:daily] = parsed_json['forecast']['simpleforecast']['forecastday']
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
    @pin = Pin.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pin }
    end
  end

  # POST /pins
  # POST /pins.json
  def create
    @pin = Pin.new(params[:pin])

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
