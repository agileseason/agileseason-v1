class @FayeCaller
  constructor: (@url, @client_id, @node) ->
    @client =  new Faye.Client(
      @url,
      timeout: 300,
      retry: 5
    )

    @client.on 'transport:down', =>
      @node.trigger "faye:disconnect"

    @log '[faye] client connect'

  apply: (channel, node) ->
    @unsubscribe channel
    @subscribe channel, node

  subscribe: (channel, node) ->
    subscription = @client.subscribe channel, (message) =>
      return if @client_id == message.client_id
      node.trigger "faye:#{message.data.action}", message.data
      @log "[faye] trigger faye:#{message.data.action}"

    @log "[faye] subscribe: #{channel}"

  unsubscribe: (channel) ->
    @client.unsubscribe channel
    @log "[faye] unsubscribe: #{channel}"

  log: (message) ->
    console.log message
