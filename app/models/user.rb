class User < ActiveRecord::Base
  attr_accessible :password, :username

  has_many :pins
end
