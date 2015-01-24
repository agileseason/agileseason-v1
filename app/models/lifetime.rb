class Lifetime < ActiveRecord::Base
  belongs_to :issue_stat
  belongs_to :column

  validates :in_at, presence: true
end
