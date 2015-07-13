require 'redcarpet'

module ApplicationHelper
  def github_token
    session[:github_token]
  end

  def encrypted_github_token
    Encryptor.encrypt(github_token)
  end

  def github_api
    @github_api ||= GithubApi.new(github_token, current_user)
  end

  def markdown(text, repo_url)
    return unless text
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(prettify: true, hard_wrap: true),
      autolink: true,
      fenced_code_blocks: true,
      highlight: true,
      lax_spacing: true, # Now it doesn't work. Partially helps hard_wrap.
      space_after_headers: true,
    )
    markdown.render(markdown_github_fixes(text, repo_url)).html_safe
  end

  def un(url)
    CGI::unescape(url)
  end

  private

  def markdown_github_fixes(text, repo_url)
    text = replace_issue_numbers(text, repo_url)
    text = replace_checkbox(text)
    text
  end

  def replace_issue_numbers(text, repo_url)
    text.gsub(/#([0-9]+)/, "<a href='#{repo_url}/issues/\\1'>#\\1</a>")
  end

  def replace_checkbox(text)
    text.
      gsub(/- \[ \] (.*)/, '<input type="checkbox" class="task"> \1</input>').
      gsub(/- \[x\] (.*)/, '<input type="checkbox" class="task" checked> \1</input>')
  end
end
