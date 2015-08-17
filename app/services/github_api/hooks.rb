class GithubApi
  module Hooks
    def apply_issues_hook(board)
      hook = hook(board, board.github_hook_id)

      if hook.nil?
        hook = try_find_hook(board)
      end

      if hook.nil?
        hook = create_issues_hook(board)
      end

      board.update(github_hook_id: hook.id)
      hook
    end

    def hook(board, id)
      client.hook(board.github_id, id) if id.present?
      rescue
    end

    def hooks(board)
      client.hooks(board.github_id)
    end

    def create_issues_hook(board)
      client.create_hook(
        board.github_id,
        'web',
        {
          url: callback_url,
          content_type: 'json',
          secret: secret,
        },
        {
          events: ['issues']
        }
      )
    end

    def try_find_hook(board)
      hooks(board).detect { |hook| hook.config.url == callback_url }
    end

    def callback_url
      'http://37847032.ngrok.io/webhooks/github'
    end

    def secret
      @secret ||= Rails.application.secrets.secret_key_base.first(20)
    end
  end
end
