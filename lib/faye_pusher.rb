class FayePusher
  URL = Rails.env.production? ? 'https://agileseason.com/faye' : 'http://localhost:9292/faye'

  def self.client
    @client ||= Faye::Client.new(URL)
  end

  # FIX : Inline parameter user (user.remember_token => client_id)
  def self.broadcast(channel, user, data)
    return unless on?

    message = {
      channel: channel,
      data: { client_id: user.remember_token, data: data },
      ext: { auth_token: config['token'] }
    }
    begin
      Net::HTTP.post_form(URI(URL), message: message.to_json)
    rescue StandardError
    end
  end

  def self.broadcast_board(user, board, data)
    broadcast(board_channel(board), user, data)
  end

  def self.board_channel(board)
    "/boards/#{board.id}/update"
  end

  def self.on?
    Rails.env.production? || ENV['FAYE_ON']
  end

  def self.config
    @config ||= YAML.load_file(Rails.root.join('config/faye.yml'))
  end
end
