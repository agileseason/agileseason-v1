module ApplicationHelper
  include Unescaper
  include MarkdownHelper
  include SubmenuHelper

  def github_token
    session[:github_token]
  end

  def encrypted_github_token
    Encryptor.encrypt(github_token)
  end

  # TODO Remove this method.
  def github_api(user = current_user)
    @github_api ||= GithubApi.new(github_token, user)
  end

  def github_avatar_url(user)
    "https://avatars.githubusercontent.com/#{user.github_username}"
  end

  def number
    params[:number].to_i
  end

  def number?
    params[:number].present?
  end
end
