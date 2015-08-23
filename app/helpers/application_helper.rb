require 'redcarpet'

module ApplicationHelper
  include Unescaper

  def github_token
    session[:github_token]
  end

  def encrypted_github_token
    Encryptor.encrypt(github_token)
  end

  def github_api
    @github_api ||= GithubApi.new(github_token, current_user)
  end

  def github_avatar_url user
    "https://avatars.githubusercontent.com/#{user.github_username}"
  end

  concerning :Markdown do
    def markdown(text, board)
      return unless text
      markdown = Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new(prettify: true, hard_wrap: true),
        autolink: true,
        fenced_code_blocks: true,
        highlight: true,
        lax_spacing: true, # Now it doesn't work. Partially helps hard_wrap.
        space_after_headers: true,
      )
      markdown.render(markdown_github_fixes(text, board)).html_safe
    end

    private

    def markdown_github_fixes(text, board)
      text = replace_issue_numbers(text, board)
      text = replace_checkbox(text)
      text
    end

    def replace_issue_numbers(text, board)
      url_prefix = un show_board_issues_url(board, '')
      text.gsub(/#([0-9]+)/, "<a href='#{url_prefix}\\1'>#\\1</a>")
    end

    def replace_checkbox(text)
      text.
        gsub(/- \[ \] (.*)/, '<input type="checkbox" class="task" />\1').
        gsub(/- \[x\] (.*)/, '<input type="checkbox" class="task" checked />\1')
    end
  end
end
