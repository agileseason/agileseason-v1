class @Issue
  constructor: (@node) ->
    @board_full_name = $('.board').data('github_full_name')
    @number = @node.data('number')

  move: (column_id) ->
    $.ajax
      url: @move_to_path(column_id)
      type: 'PATCH',
      beforeSend: =>
        return if column_id == @node.data('column')
        @node.find('.is_ready').removeClass('active')
        $column = $("#column_#{column_id}")
        if $column.data('auto-close')
          @node.addClass('closed')

        if $column.data('auto-assign')
          $board = $('.board')
          login = $board.data('login')
          htmlUrl = $board.data('html-url')
          avatarUrl = $board.data('avatar-url')
          @node.find('.b-assignee.js-assignee-none').replaceWith(
            "<div class='b-assignee'><a class='user' href='#{htmlUrl}' title='#{login}'>" +
            "<img class='avatar' src='#{avatarUrl}' /></a></div>"
          )

      success: (data) ->
        window.update_wip_column(badge) for badge in data.badges

  move_to_path: (column_id) ->
    "/boards/#{@board_full_name}/issues/#{@number}/moves/#{column_id}"
