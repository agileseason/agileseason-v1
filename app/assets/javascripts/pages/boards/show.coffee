resize_lock = false

$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'
  new NewIssueForm $('.board-column:first')
  column_menu()
  subscribe_board_update()
  resize_height() # высота борда подгоняется под высоту браузера

  # перейти на страницу тикета
  $('.issues').on 'click', '.issue.draggable', (e) ->
    unless $(e.target).is 'a, .button, button'
      $(@).closest('.issue').addClass 'current-issue'
      Turbolinks.visit $(@).data 'url'

  # скрыть тикет после архивации
  $('.board').on 'click', '.issue .archive', ->
    $(@).closest('.issue').addClass 'hidden'

  # обновить WIP у колонки после архивации тикета
  $('.issue .archive').on 'ajax:success', (e, badge) ->
    window.update_wip_column(badge)

  # изменить тикет и открыть архивацию после успешного закрытия
  $('.board').on 'click', '.issue .close', ->
    $(@).closest('.issue').addClass('closed').removeClass 'open'
    $(@).next('.archive').removeClass('hidden')
    $(@).remove()

  # кнопака «ready»
  $('.board').on 'ajax:before', '.is_ready', ->
    $(@).toggleClass 'active'

$(window).resize ->
  return unless document.body.id == 'boards_show' & !resize_lock
  resize_lock = true
  setTimeout ->
      resize_height()
    , 400

# пересчитать высоту борда
resize_height = ->
  resize_lock = false

  height = $(window).height() - $('.b-menu').outerHeight(true)
  $('.board').height height

column_menu = ->
  $('.column-menu').each ->
    new ColumnsSettings $(@)

  $('.column-menu .title a').on 'click', ->
    $menu = $(@).closest '.column-menu'
    $('.column-settings-popup', $menu).show()
    $menu.addClass('active').prepend '<div class="overlay"></div>'

  $('.board-column .column-menu').on 'click', '.overlay', ->
    $(@).parent().find('.column-settings-popup').hide()
    $(@).parent().removeClass 'active'
    $(@).remove()

window.update_wip_column = (badge) ->
  $("#column_#{badge.column_id}")
    .find '.badge'
    .replaceWith badge.html
