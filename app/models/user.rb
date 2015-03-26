class User < ActiveRecord::Base
  has_many :boards

  before_create :generate_remember_token

  alias_attribute :login, :github_username

  attr_accessor :github_api

  def to_s
    github_username
  end

  # FIX : remove after check ability
  def owner?(board)
    board.user_id == id
  end

  def repo_admin?(github_id)
    repo = github_api.cached_repos.select { |r| r.id == github_id.to_i }.first
    repo.permissions.admin
  end

  private

  def generate_remember_token
    self.remember_token = SecureRandom.hex(20)
  end
end
