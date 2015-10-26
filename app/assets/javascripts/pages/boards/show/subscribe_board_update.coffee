window.subscribe_board_update = ->
  $board = $('.board')
  return unless $board.data('faye-on')

  try
    unless window.faye
      window.faye = new FayeCaller(
        $board.data('faye-url'),
        $board.data('faye-client-id'),
        $board
      )

    window.faye.apply($board.data('faye-channel'), $board)

    $board.on 'faye:update_column', (e, data) ->
      window.faye.updateProcessTime()
      # NOTE Timeout because sometimes by this time column not updated.
      window.setTimeout (->
          column = $("#column_#{data.column_id}")
          $.get(
            column.data('url')
            (data) ->
              column.find('.issues').html(data.html)
          )
        ), 1000

    $board.on 'faye:disconnect', ->
      # TODO remove this log after test faye
      console.log "[faye client] lastConnectedAt: #{window.faye.lastConnectedAt}, now: #{new Date()}"
      timeout = 1000 * 60 * 30
      $('.alert-timeout').show() if window.faye.lastActionAt() < new Date() - timeout

  catch err
    console.log err
