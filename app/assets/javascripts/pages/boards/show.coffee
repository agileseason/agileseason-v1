resize_lock = false

$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'
  column_menu()
  new_issue_forms()
  subscribe_board_update()

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
    $(@).closest('.issue').addClass('hidden')

  # обновить WIP у колонки после архивации тикета
  $('.issue .archive').on 'ajax:success', (e, badge) ->
    window.update_wip_column(badge)

  # изменить тикет и открыть архивацию после успешного закрытия
  $('.board').on 'click', '.issue .close', ->
    $(@).closest('.issue').addClass('closed').removeClass('open')
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
  $('.board').height(height)

column_menu = ->
  $('.column-menu .title a').on 'ajax:success', (e, data) ->
    $menu = $(@).closest('.column-menu')
    $menu.addClass('active').prepend('<div class="overlay"></div>')
    $menu.find('.column-settings-popup').html(data.content).show()
    new ColumnsSettings $menu

  $('.board-column .column-menu').on 'click', '.overlay', ->
    $(@).parent().find('.column-settings-popup').hide()
    $(@).parent().removeClass 'active'
    $(@).remove()

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

    window.faye.apply($board.data('faye-channel'), $board)

    $board.on 'faye:update_column', (e, data) ->
      window.faye.updateProcessTime()
      # NOTE Timeout because sometimes by this time column not updated.
      window.setTimeout (->
          column = $("#column_#{data.column_id}")
          $.get(
            column.data('url')
            (data) ->
              column.find('.issues').html(data.html)
          )
        ), 1000

    $board.on 'faye:disconnect', ->
      # TODO remove this log after test faye
      console.log "[faye client] lastConnectedAt: #{window.faye.lastConnectedAt}, now: #{new Date()}"
      timeout = 1000 * 60 * 30
      $('.alert-timeout').show() if window.faye.lastActionAt() < new Date() - timeout

  catch err
    console.log err
