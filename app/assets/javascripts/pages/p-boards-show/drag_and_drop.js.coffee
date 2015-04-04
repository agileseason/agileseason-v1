$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  $(".droppable").droppable ->
    accept: ".issue"

  $(".droppable").on "drop", (event, ui) ->
    issue = $(".ui-draggable-dragging").data('number')
    column = $(@).data('column')
    $(".ui-draggable-dragging").removeAttr('style')

    unless $(".ui-draggable-dragging").data('start_column') == column
      $(".ui-draggable-dragging").prependTo($(@).find('.issues'))
      $(@).removeClass 'over'
      board_github_full_name = $('.board').data('github_full_name')
      path = "/boards/#{board_github_full_name}/issues/#{issue}/move_to/#{column}"
      $.get path

  $(".droppable").on "dropout", (event, ui) ->
    $(@).removeClass 'over'

  $(".droppable").on "dropover", (event, ui) ->
    $(@).addClass 'over'

  $(".draggable").draggable ->
    connectToSortable: ".issues",
    helper: "clone",
    revert: "valid",
    snap: true,
    scroll: true

  $(".draggable").on "dragstart", ( event, ui ) ->
    $(@).before('<div class="empty-issue"></div>')
    $('.empty-issue', $(@).parent()).css 'height', $(@).outerHeight()
    $(@).data start_column: $(@).parents('.board-column').data('column')

  $(".draggable").on "drag", ( event, ui ) ->
    ui.position.top -= $(@).parent().scrollTop()
    $(@).closest('.scroller').scrollTop = $(@).closest('.scroller').scrollHeight

  $(".draggable").on "dragstop", ( event, ui ) ->
    $(@).removeAttr('style')
    $('.empty-issue').remove()
    $('.board-column').removeClass 'over'

  $(".draggable").on "dragcreate", ( event, ui ) ->
