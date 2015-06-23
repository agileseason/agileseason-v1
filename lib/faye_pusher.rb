class FayePusher
  URL = 'http://localhost:9292/faye'

  def self.client
    @client ||= Faye::Client.new(URL)
  end

  def self.broadcast(channel, user, data)
    message = {
      channel: channel,
      data: { client_id: user.remember_token, data: data },
      #ext: { auth_token: FAYE_TOKEN }
    }
    Net::HTTP.post_form(URI(URL), message: message.to_json)
  end

  def self.broadcast_board(user, board, data)
    broadcast(board_channel(board), user, data)
  end

  def self.board_channel(board)
    "/boards/#{board.id}/update"
  end
end
