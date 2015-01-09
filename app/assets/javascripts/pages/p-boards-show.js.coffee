resize_lock = false

$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  $('.issue-name').click ->
    $('.l-preloader').show()

  resize_height()

$(window).resize ->
  return unless document.body.id == 'boards_show' & !resize_lock
  resize_lock = true
  setTimeout ->
      resize_height()
    , 400

resize_height = ->
  resize_lock = false

  height = $(window).height() - $('.l-menu').outerHeight(true) - $('.l-submenu').outerHeight(true)
  $('.board').height(height)
