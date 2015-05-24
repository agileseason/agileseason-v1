require 'redcarpet'

module ApplicationHelper
  def github_token
    session[:github_token]
  end

  def github_api
    @github_api ||= GithubApi.new(github_token, current_user)
  end

  def markdown(text, repo_url)
    return unless text
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(prettify: true),
      fenced_code_blocks: true,
      highlight: true,
      autolink: true
    )
    markdown.render(
      replace_issue_numbers(fix_new_line(text), repo_url)
    ).html_safe
  end

  private

  def replace_issue_numbers(text, repo_url)
    text.gsub(/#([0-9]+)/, "<a href='#{repo_url}/issues/\\1' target='_blank'>#\\1</a>")
  end

  def fix_new_line(text)
    text.gsub("\n", '<br />')
  end
end
