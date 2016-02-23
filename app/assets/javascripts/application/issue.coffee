class @Issue
  constructor: (@node) ->
    @board_full_name = $('.board').data('github_full_name')
    @number = @node.data('number')

  move: (column_id) ->
    console.log "move: #{column_id}"
    console.log @move_to_path(column_id)

    $.ajax
      url: @move_to_path(column_id)
      beforeSend: =>
        return if column_id == @node.data('column')
        @node.find('.is_ready').removeClass('active')

      success: (data) =>
        @node.find('.b-assignee').replaceWith(data.assignee)
        if data.is_open
          @node.removeClass('closed')
        else
          @node.addClass('closed')

        window.update_wip_column(badge) for badge in data.badges

  move_to_path: (column_id) ->
    "/boards/#{@board_full_name}/issues/#{@number}/move_to/#{column_id}"
