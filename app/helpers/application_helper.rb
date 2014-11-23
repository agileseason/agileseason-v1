module ApplicationHelper
  def github_token
    session[:github_token]
  end

  def github_api
    @github_api ||= GithubApi.new(github_token)
  end
end
