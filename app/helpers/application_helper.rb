require 'redcarpet'

module ApplicationHelper
  def github_token
    session[:github_token]
  end

  def github_api
    @github_api ||= GithubApi.new(github_token, current_user)
  end

  def markdown(text)
    if text
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(prettify: true),
        fenced_code_blocks: true,
        highlight: true,
        autolink: true)
      markdown.render(text).html_safe
    end
  end
end
