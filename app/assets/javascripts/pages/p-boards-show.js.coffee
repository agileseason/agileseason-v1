resize_lock = false

$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  $('.l-modal').on 'click', '.edit-description', ->
    $(@).toggleClass 'active'
    $(@).parent().find('.description').toggle()
    $(@).parent().find('.edit-form').toggle()
    #console.log $(@).data('url')
    #data = '12312312312'
    #$.get $(@).data('url'), { body: data }

  $('.l-modal').on 'click', '.edit-form .cancel', ->
    $(@).parents('.issue-description').find('.edit-description').removeClass 'active'
    $(@).parents('.issue-description').find('.description').show()
    $(@).parents('.issue-description').find('.edit-form').hide()

  $('.l-modal').on 'click', '.edit-form button', ->
    body = $('textarea', $(@).parents('.edit-form')).val()
    console.log body
    $.get $(@).attr('href'), { body: body }, =>
      $(@).parents('.issue-description').find('.edit-description').removeClass 'active'
      $(@).parents('.issue-description').find('.description').html(body).show()
      $(@).parents('.issue-description').find('.edit-form').hide()

  $(".droppable").droppable ->
    accept: ".issue"

  $(".droppable").on "drop", (event, ui) ->
    issue = $(".ui-draggable-dragging").data('number')
    column = $(@).data('column')
    $(".ui-draggable-dragging").removeAttr('style')

    unless $(".ui-draggable-dragging").data('start_column') == column
      $(".ui-draggable-dragging").prependTo($(@).find('.issues'))
      $(@).removeClass 'over'
      board_github_name = $('.board').data('github_name')
      path = "/boards/#{board_github_name}/issues/#{issue}/move_to/#{column}"
      $.get path

  $(".droppable").on "dropout", (event, ui) ->
    $(@).removeClass 'over'

  $(".droppable").on "dropover", (event, ui) ->
    $(@).addClass 'over'

  $(".draggable").draggable ->
    connectToSortable: ".issues",
    helper: "clone",
    revert: "valid",
    snap: true,
    scrollSensitivity: 100

  $(".draggable").on "dragstart", ( event, ui ) ->
    $(@).before('<div class="empty-issue"></div>')
    $('.empty-issue', $(@).parent()).css 'height', $(@).outerHeight()
    $(@).data start_column: $(@).parents('.board-column').data('column')

  $(".draggable").on "dragstop", ( event, ui ) ->
    $(@).removeAttr('style')
    $('.empty-issue').remove()
    $('.board-column').removeClass 'over'

  $(".draggable").on "dragcreate", ( event, ui ) ->
    $(@).parent().scrollTo @

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
