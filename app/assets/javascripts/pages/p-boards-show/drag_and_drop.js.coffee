$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  $('.issues').sortable connectWith: '.issues'
  $('.issues').sortable
    connectWith: '.issues'
  $('.issues').disableSelection()

  $(".droppable").droppable ->
    accept: ".issue"

  $(".droppable").on "drop", (event, ui) ->
    issue = $(".ui-sortable-helper").data('number')
    column = $(@).data('column')
    $(".ui-draggable-dragging").removeAttr('style')

    unless $(".ui-draggable-dragging").data('start_column') == column
      $(".ui-draggable-dragging").prependTo($(@).find('.issues'))
      $(@).removeClass 'over'
      board_github_name = $('.board').data('github_name')
      path = "/boards/#{board_github_name}/issues/#{issue}/move_to/#{column}"
      $.get path

  $(".droppable").on "dropout", (event, ui) ->
    $(@).removeClass 'over'

  $(".droppable").on "dropover", (event, ui) ->
    $(@).addClass 'over'
    $(@).find('.issues').css('height', $(@).height())
