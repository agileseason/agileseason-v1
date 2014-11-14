class Board < ActiveRecord::Base
  belongs_to :user

  validates :name, presence: true
  validates :type, presence: true
end
