class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :board

  validates :date_to, presence: true
  validates :cost, numericality: { greater_than_or_equal_to: 0 }
end
