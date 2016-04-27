class @FayeCaller
  constructor: (@url, @client_id, @node) ->
    @client =  new Faye.Client(
      @url,
      timeout: 300,
      retry: 5
    )
    @channels = []
    @subscriptions = {}
    @lastConnectedAt = null
    @lastProcessedAt = null

    @client.on 'transport:down', =>
      @node.trigger 'faye:disconnect'
      @log 'client disconnect'

    @log 'client connect'

  apply: (channel, node) ->
    @unsubscribe exist_channel for exist_channel in @channels
    @subscribe channel, node

  subscribe: (channel, node) ->
    @subscriptions[channel] = @client.subscribe channel, (message) =>
      return if @client_id == message.client_id
      node.trigger "faye:#{message.data.action}", message.data
      @log "trigger faye:#{message.data.action},
        client_id: #{message.client_id}, data:#{JSON.stringify(message.data)}"

    @channels.push channel
    @lastConnectedAt = new Date()
    @log "subscribe: #{channel}"

  unsubscribe: (channel) ->
    @client.unsubscribe channel
    @deleteFromChannels channel

    subscription = @subscriptions[channel]
    subscription.cancel() if subscription
    @deleteFromSubscriptions channel

    @log "unsubscribe: #{channel}"

  log: (message) ->
    time = new Date().toLocaleTimeString().toString()
    console.log "[faye][#{time}] #{message}"

  lastActionAt: ->
    if @lastConnectedAt > @lastProcessedAt then @lastConnectedAt else @lastProcessedAt

  updateProcessTime: ->
    @lastProcessedAt = new Date()

  deleteFromChannels: (channel) ->
    index = @channels.indexOf channel
    @channels.splice(index, 1) if index >= 0

  deleteFromSubscriptions: (channel) ->
    delete @subscriptions[channel]
