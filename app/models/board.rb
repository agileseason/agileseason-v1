class Board < ActiveRecord::Base
  belongs_to :user
  has_many :columns

  validates :name, presence: true
  validates :type, presence: true
  validates :columns, presence: true
end
