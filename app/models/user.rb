class User < ActiveRecord::Base
  has_many :boards
  has_many :subscriptions

  before_create :generate_remember_token

  alias_attribute :login, :github_username

  attr_accessor :github_api

  BLACKCHESTNUT_ID = 1
  SFOLT_ID = 2
  ADMINS = [BLACKCHESTNUT_ID, SFOLT_ID].freeze
  GUEST = User.new(
    github_username: 'Guest',
    github_api: GithubApiGuest.new,
    remember_token: 'guest_token'
  ).freeze

  def to_s
    github_username
  end

  def repo_admin?(github_id)
    repo = github_api.cached_repos.detect { |r| r.id == github_id.to_i }
    repo && repo.permissions.admin # try don't work before directly call method
  end

  def admin?
    ADMINS.include?(id)
  end

  def guest?
    id.nil?
  end

  def github_url
    return '#' if guest?
    "https://github.com/#{github_username}"
  end

private

  def generate_remember_token
    self.remember_token = SecureRandom.hex(20)
  end
end
