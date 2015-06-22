class FayePusher
  URL = 'http://localhost:9292/faye'

  def self.client
    @client ||= Faye::Client.new(URL)
  end

  def self.broadcast(channel, data)
    message = { channel: channel, data: data, ext: { auth_token: ENV['FAYE_TOKEN'] } }
    Net::HTTP.post_form(URI(URL), message: message.to_json)
  end
end
