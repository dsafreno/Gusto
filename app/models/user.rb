class User < ActiveRecord::Base
  attr_accessible :password, :username

  has_many :pins

  validates :username, presence: true
  validates :username, uniqueness: true
  validates :username, length: {in: 4..20}
  validates :password, length: {in: 7..20}
end
