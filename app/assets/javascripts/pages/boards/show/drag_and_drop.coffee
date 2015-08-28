$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  $('.issues')
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
          $("#issues_#{data.number}").replaceWith(data.html_miniature)
          window.update_wip_column(badge) for badge in data.badges
          click_ready_button $("#issues_#{data.number}")

click_ready_button = ($current_issue) ->
  $ready_button = $('.is_ready', $current_issue)

  if $ready_button.hasClass 'active'
    $('.issue_stat_is_ready input', $current_issue).val('false')

    setTimeout ->
      $('input:submit', $current_issue).trigger 'click'
      $ready_button.removeClass 'active'
