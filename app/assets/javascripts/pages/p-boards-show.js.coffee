resize_lock = false

$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  # показать прелоадер перед попапом с данными тикета
  $('.issue-name').click ->
    $('.l-preloader').show()

  # открыть форму добавления тикета
  $('.new-issue').click ->
    $(@).next()
      .show()
      .find('#issue_title').focus()
    $(@).hide()

  # закрыть форму тикета
  $('.board-column').on 'click', '.cancel', ->
    $(@).closest('.new-issue-form').prev().show()
    $(@).closest('.new-issue-form').hide()
    false

  # раскрыть попап с лейблами тикета
  $('.board-column').on 'click', '.add-label', ->
    $(@).parent().prev().show()
    $(@).hide()

  # скрыть попап с лейблами тикета
  $('.board-column').on 'click', '.close-popover', ->
    $(@).closest('.popover').next().find('.add-label').show()
    $(@).closest('.popover').hide()

  # указать высоту борда в зависимости от высоты окна браузера
  resize_height()

$(window).resize ->
  return unless document.body.id == 'boards_show' & !resize_lock
  resize_lock = true
  setTimeout ->
      # указать высоту борда при ресайзе
      resize_height()
    , 400

resize_height = ->
  resize_lock = false

  height = $(window).height() - $('.l-menu').outerHeight(true) - $('.l-submenu').outerHeight(true)
  $('.board').height(height)
