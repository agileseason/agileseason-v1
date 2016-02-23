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
        $column = $("#column_#{column_id}")
        if $column.data('auto-close')
          @node.addClass('closed')

      success: (data) =>
        @node.find('.b-assignee').replaceWith(data.assignee)
        window.update_wip_column(badge) for badge in data.badges

  move_to_path: (column_id) ->
    "/boards/#{@board_full_name}/issues/#{@number}/move_to/#{column_id}"
