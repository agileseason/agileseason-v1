class User < ActiveRecord::Base
  has_many :boards

  before_create :generate_remember_token

  def to_s
    github_username
  end

  def owner?(board)
    boards.find_by(id: board.id).present?
  end

  private

  def generate_remember_token
    self.remember_token = SecureRandom.hex(20)
  end
end
