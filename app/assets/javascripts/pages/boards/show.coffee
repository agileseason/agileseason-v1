resize_lock = false

$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'
  new NewIssueForm $('.board-column:first')
  subscribe_board_update()
  resize_height() # высота борда подгоняется под высоту браузера

  $('.column-menu').each -> new ColumnsSettings($(@))

  # перейти на страницу тикета
  $('.issues').on 'click', '.issue', (e) ->
    unless $(e.target).is 'a, .button, button'
      window.showModal($(@).data('issue'))

  $('.issue-modal-container').on 'click', (e) ->
    $target = $(e.target)
    if $target.is '.issue-modal-container'
      $('.close-modal', $target).trigger 'click'
      false

  # скрыть тикет после архивации
  $('.board').on 'click', '.issue .archive', ->
    $(@).closest('.issue').addClass 'hidden'

  # обновить WIP у колонки после архивации тикета
  $('.issue .archive').on 'ajax:success', (e, badge) ->
    window.update_wip_column(JSON.parse(badge))

  # изменить тикет и открыть архивацию после успешного закрытия
  $('.board').on 'click', '.issue .close', ->
    $(@).closest('.issue').addClass('closed').removeClass 'open'
    $(@).next('.archive').removeClass('hidden')
    $(@).remove()

  # кнопака «ready»
  $('.board').on 'ajax:before', '.is_ready', ->
    $(@).toggleClass 'active'

  directIssue = $('.issue-modal-container').data('direct_issue')
  if directIssue
    setTimeout ->
        window.showModal(directIssue)
      , 50

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

window.update_wip_column = (badge) ->
  $("#column_#{badge.column_id}")
    .find '.badge'
    .replaceWith badge.html

window.showModal = (issue) ->
  $container = $('.issue-modal-container')
  $container.find('.issue-modal').empty()
  window.IssueModalRender(
    issue
    $('.board').data('github_full_name'),
    $('.board').data('readonly') == 'readonly',
  )
  $container.show()
