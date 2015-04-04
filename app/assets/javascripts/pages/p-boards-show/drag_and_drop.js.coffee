$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  $('.issues').sortable
    connectWith: '.issues',
  $('.issues').disableSelection()

  # сохранение порядка тикетов, если он изменился
  $('.issues').on 'sortupdate', (event, ui) ->
    column = $(event.target).closest('.board-column').data('column')
    board_github_name = $('.board').data('github_name')
    path = "/boards/#{board_github_name}/columns/#{column}"

    if $(event.target).sortable('serialize')
      issues = $(event.target).sortable('serialize')
    else
      # колонка стала пустой
      issues =  { issues: ['empty'] }

    $.ajax
      url: path,
      method: 'PATCH',
      data: issues

  $(".droppable").droppable ->
    accept: ".issue"

  $(".droppable").on "drop", (event, ui) ->
    issue_number = $(".ui-sortable-helper").data('number')
    column_number = $(@).data('column')
    $current_issue = $('.issue[data-number="' + issue_number + '"]')
    board = $('.board').data('github_name')

    unless $(".ui-draggable-dragging").data('start_column') == column_number
      $(".ui-draggable-dragging").prependTo($(@).find('.issues'))
      $(@).removeClass 'over'
      move_to_path = "/boards/#{board}/issues/#{issue_number}/move_to/#{column_number}"
      $.get move_to_path

  $(".droppable").on "dropout", (event, ui) ->
    $(@).removeClass 'over'

  $(".droppable").on "dropover", (event, ui) ->
    $(@).addClass 'over'
    $(@).find('.issues').css('height', $(@).height())
