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
      console.log "[faye client] lastConnectedAt: #{window.faye.lastConnectedAt}, now: #{new Date()}"
      timeout = 1000 * 60 * 20
      if window.faye.lastActionAt() < new Date() - timeout
        if $('#issue-modal').is(':hidden')
          $('.loading').removeClass('hidden')
          # window.location.reload() - Remove if Turbolinks.visit will be work fine.
          Turbolinks.visit($board.data('url'))

  catch e
    console.error e
