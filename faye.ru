# Development
# rackup faye.ru -s thin -E production

require 'faye'
require 'psych'

CONFIG = Psych.load_file(File.expand_path(File.dirname(__FILE__) + '/config/faye.yml'))

#puts CONFIG

class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      msg_token = message['ext'] && message['ext']['auth_token']

      #puts message
      if msg_token == CONFIG['token']
        message['data'].delete('token')
      else
        message['error'] = 'Invalid authentication token.'
      end
    end

    callback.call(message)
  end
end

Faye::WebSocket.load_adapter('thin')
faye_server = Faye::RackAdapter.new(mount: '/faye', timeout: 30)
faye_server.add_extension(ServerAuth.new)

run faye_server
