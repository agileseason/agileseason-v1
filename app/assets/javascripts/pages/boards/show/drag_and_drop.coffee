$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  $('.issues.js-can-update')
    .sortable
      connectWith: '.issues',
      forcePlaceholderSize: true,

    .disableSelection()

    .on 'sortupdate', (event, ui) ->
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

    .on 'sortstop', (event, ui) ->
      $current_issue = $(ui.item)
      column_number = $current_issue.closest('.board-column').data('column')
      board = $('.board').data('github_full_name')

      new Issue($current_issue).move(column_number)
