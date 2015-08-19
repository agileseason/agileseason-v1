resize_lock = false

$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'
  column_menu()
  new_issue_forms()
  subscribe_board_update()
  $.initJsPathForInputs()

  # пересчитать высоту борда в зависимости от высоты окна браузера
  resize_height()

  # открыть форму добавления тикета или колонки
  $('.new-issue, .new-column').click ->
    $(@).next().show()
    $('textarea, input:text', $(@).next()).first().focus()

  # закрыть форму создания тикета или колонки
  $('.board-column').on 'click', '.cancel', ->
    $(@).closest('.create-column, .create-issue').hide()
    false

  # закрыть форму создания тикета по клику на оверлей
  $('.create-issue').click (e) ->
    if $(e.target).is('.create-issue')
      $(@).hide()
      false

  # раскрыть попап с лейблами тикета
  $('.board-column').on 'click', '.add-label', ->
    $(@).parent().prev().show()
    $(@).hide()

  # скрыть попап с лейблами тикета
  $('.board-column').on 'click', '.close-popup', ->
    $(@).closest('.popup').next().find('.add-label').show()
    $(@).closest('.popup').hide()

  # скрыть тикет после архивации
  $('.board').on 'click', '.issue .archive', ->
    $(@).parent('.issue').addClass('hidden')

  # обновить WIP у колонки после архивации тикета
  $('.issue .archive').on 'ajax:success', (e, badge) ->
    window.update_wip_column(badge)

  # изменить тикет и открыть архивацию после успешного закрытия
  $('.board').on 'click', '.issue .close', ->
    $(@).parent('.issue').addClass('closed').removeClass('open')
    $(@).next('.archive').removeClass('hidden')
    $(@).remove()

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
  $('.board').height(height)

column_menu = ->
  $('.board-column').on 'click', '.column-menu .octicon', ->
    $menu = $(@).closest('.column-menu')
    $menu.addClass('active').prepend('<div class="overlay"></div>')
    $menu.find('.popup').show()

  $('.board-column .column-menu').on 'click', '.overlay', ->
    $(@).parent().find('.popup').hide()
    $(@).parent().removeClass 'active'
    $(@).remove()

  $('.column-menu .delete').bind 'ajax:success', (e, data) ->
    if data.result
      $(".board-column[data-column='#{data.id}']").hide()
    else
      alert(data.message)

new_issue_forms = ->
  $('textarea', '.new_issue').elastic()

  $('form.new_issue').on 'submit', ->
    $form = $(@)
    if $form.data('blocked')
      false
    else
      $form.data('blocked', true)

  $('form.new_issue').on 'ajax:success', (e, data) ->
    $form = $(@)
    $form.removeData('blocked')

    return if data == ''

    $form.find('textarea').val('') # в данном случае нужно очищать поле ввода
    $form.find('label input').prop('checked', false)
    $('.cancel', @).trigger 'click'

    $issues = $('.issues', $form.closest('.board-column'))
    $issues.prepend(data)

window.update_wip_column = (badge) ->
  $("#column_#{badge.column_id}").find('.badge').replaceWith(badge.html)

subscribe_board_update = ->
  $board = $('.board')
  return unless $board.data('faye-on')

  try
    unless window.faye
      window.faye = new FayeCaller(
        $board.data('faye-url'),
        $board.data('faye-client-id'),
        $board
      )

    window.faye.apply $board.data('faye-channel'), $board

    $board.on 'faye:update_column', (e, data) ->
      column = $("#column_#{data.column_id}")
      $.get(
        column.data('url')
        (data) ->
          column.find('.issues').html(data.html)
      )

    $board.on 'faye:disconnect', ->
      window.setTimeout (-> $('.alert-timeout').show()), 1000 * 60 * 5

  catch err
    console.log err
