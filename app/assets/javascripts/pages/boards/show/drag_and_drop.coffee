$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  $('.issues.js-can-update').sortable
    connectWith: '.issues',
  $('.issues').disableSelection()

  # сохранение порядка тикетов, если он изменился
  $('.issues').on 'sortupdate', (event, ui) ->
    column = $(event.target).closest('.board-column').data('column')
    board = $('.board').data('github_full_name')
    path = "/boards/#{board}/columns/#{column}"

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
    board = $('.board').data('github_full_name')

    # FIX : Where data-start_colum set? Now this condition always true.
    unless $(".ui-draggable-dragging").data('start_column') == column_number
      $(".ui-draggable-dragging").prependTo($(@).find('.issues'))
      $(@).removeClass 'over'
      move_to_path = "/boards/#{board}/issues/#{issue_number}/move_to/#{column_number}"
      $.ajax
        url: move_to_path
        success: (badges) -> window.update_wip_column(badge) for badge in badges

  $(".droppable").on "dropout", (event, ui) ->
    $(@).removeClass 'over'

  $(".droppable").on "dropover", (event, ui) ->
    $(@).addClass 'over'
    $(@).find('.issues').css('height', $(@).height())
