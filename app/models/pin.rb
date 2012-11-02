class Pin < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :user_id

  belongs_to :user

  validates :user_id, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :latitude, numericality:
    {less_than_or_equal_to: 90.0, greater_than_or_equal_to: -90.0 }
  validates :longitude, numericality:
    {less_than_or_equal_to: 90.0, greater_than_or_equal_to: -90.0 }
end
