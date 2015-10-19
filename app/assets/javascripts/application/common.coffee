# скрипт выплняется на всех страницах
$(document).on 'page:change', ->
  $('.notice').on 'click', -> $(@).remove()

  # закрыть дашборд по крестику или по клику мимо
  $('.overlay, .close-settings', '.settings-modal').on 'click', ->
    $modal = $(@).closest '.modal'
    $content = $('> .modal-content', $modal)
    $content.children().trigger 'modal:close'
    $modal.hide()
    # страница борда
    return unless document.body.id == 'boards_show'

  if $('.b-menu').length
    show_dashboard()
    new SearchIssue $('.b-menu .search')
    new Activities $('.b-menu .activities')

show_dashboard = ->
  $('.b-menu .left-menu-link').click ->
    $issue_modal = $('.settings-modal')
    $board_list = $('.board-lists', $issue_modal)
    $issue_modal.show()

    unless $('.board-list ul', $issue_modal).length
      $('.b-preloader', $board_list).show()

      $.ajax
        url: $(@).data('url'),
        success: (html) ->
          $('.b-preloader', $board_list).hide()
          $board_list.html $(html)
          new Dashboard $('.b-dashboard')
