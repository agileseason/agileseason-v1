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
      issue_number = $current_issue.data('number')
      column_number = $current_issue.closest('.board-column').data('column')
      board = $('.board').data('github_full_name')

      move_to_path = "/boards/#{board}/issues/#{issue_number}/move_to/#{column_number}"
      $.ajax
        url: move_to_path
        success: (data) ->
          $issue = $("#issues_#{data.number}")
          $issue.find('.b-assignee').replaceWith(data.assignee)

          if data.is_ready
            $issue.find('.is_ready').addClass('active')
          else
            $issue.find('.is_ready').removeClass('active')

          if data.is_open
            $issue.removeClass('closed')
          else
            $issue.addClass('closed')

          window.update_wip_column(badge) for badge in data.badges
