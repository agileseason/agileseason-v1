#rackup faye.ru -s thin -E production

require 'faye'
require File.expand_path('../config/initializers/faye_token.rb', __FILE__)

class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      msg_token = message['ext'] && message['ext']['auth_token']

      if msg_token != FAYE_TOKEN
        message['error'] = 'Invalid authentication token.'
      end
    end

    callback.call(message)
  end
end

Faye::WebSocket.load_adapter('thin')
faye_server = Faye::RackAdapter.new(mount: '/faye', timeout: 25)
faye_server.add_extension(ServerAuth.new)

run faye_server
