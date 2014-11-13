module ApplicationHelper
  def github_token
    session[:github_token]
  end
end
