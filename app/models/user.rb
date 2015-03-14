class User < ActiveRecord::Base
  has_many :boards

  before_create :generate_remember_token

  alias_attribute :login, :github_username

  def to_s
    github_username
  end

  def owner?(board)
    board.user_id == id
  end

  private

  def generate_remember_token
    self.remember_token = SecureRandom.hex(20)
  end
end
