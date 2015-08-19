class @FayeCaller
  constructor: (@url, @client_id, @node) ->
    @client =  new Faye.Client(
      @url,
      timeout: 300,
      retry: 5
    )
    @channels = []

    @client.on 'transport:down', =>
      @node.trigger "faye:disconnect"

    @log '[faye] client connect'

  apply: (channel, node) ->
    @unsubscribe exist_channel for exist_channel in @channels
    @subscribe channel, node

  subscribe: (channel, node) ->
    subscription = @client.subscribe channel, (message) =>
      return if @client_id == message.client_id
      node.trigger "faye:#{message.data.action}", message.data
      @log "[faye] trigger faye:#{message.data.action}"

    @channels.push channel
    @log "[faye] subscribe: #{channel}"

  unsubscribe: (channel) ->
    @client.unsubscribe channel

    index = @channels.indexOf channel
    @channels.splice(index, 1) if index >= 0

    @log "[faye] unsubscribe: #{channel}"

  log: (message) ->
    console.log message
