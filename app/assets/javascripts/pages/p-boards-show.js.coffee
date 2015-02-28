resize_lock = false

column_menu = ->
  $('.board-column').on 'click', '.column-menu', ->
    $(@).addClass('active').prepend('<div class="overlay"></div>')
    $(@).find('.popup').show()

  $('.board-column .column-menu').on 'click', '.overlay', ->
    $(@).parent().find('.popup').hide()
    $(@).parent().removeClass 'active'
    $(@).remove()

  $('.column-menu .delete').bind 'ajax:success', (e, data) ->
    if data.result
      $(".board-column[data-column='#{data.id}']").hide()
    else
      alert(data.message)

$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'
  column_menu()

  $(document).on 'click', '.show-issue-modal', ->
    $(@).closest('.issue').addClass 'current-issue'
    $issue_data = $(@).closest('.issue').find('.issue-data').html()
    $issue_modal = $('.issue-modal')
    $('.modal-content', $issue_modal).html $issue_data
    $issue_modal.show()
    $('.b-issue-modal', $issue_modal).show()

    comments_url = $('.issue-comments', $issue_modal).data('url')
    $.get comments_url, (comments) ->
      $('.issue-comments', $issue_modal).append(comments)
      $('.b-preloader', $issue_modal).hide()

    $('.modal-content', $issue_modal).children().trigger 'modal:load'

  # закрыть попап по крестику или по клику мимо попапа
  $('.issue-modal').on 'click', '.modal-close, .overlay', ->
    $modal = $(@).closest('.issue-modal')
    $content = $('> .modal-content', $modal)
    $content.children().trigger 'modal:close'
    $modal.hide()
    $('.b-issue-modal', $modal).remove()

    # страница борда
    return unless document.body.id == 'boards_show'

  # открыть форму добавления тикета или колонки
  $('.new-issue, .new-column').click ->
    $(@).next().show()
    $('textarea', $(@).next()).first().focus()
    $(@).hide()

  # закрыть форму создания тикета или колонки
  $('.board-column').on 'click', '.cancel', ->
    $(@).closest('.inline-form').prev().show()
    $(@).closest('.inline-form').hide()
    false

  # раскрыть попап с лейблами тикета
  $('.board-column, .issue-modal').on 'click', '.add-label', ->
    $(@).parent().prev().show()
    $(@).hide()

  # скрыть попап с лейблами тикета
  $('.board-column, .issue-modal').on 'click', '.close-popup', ->
    $(@).closest('.popup').next().find('.add-label').show()
    $(@).closest('.popup').hide()

  # изменить набор лейблов тикета
  $('.board-column, .issue-modal').on 'change', 'label input', ->
    labels = []
    html_labels = []
    $(@).parents('.labels-block').find('input:checked').each ->
      labels.push $(@).val()
      html_labels.push('<div class="label" style="' + $(@).parent().attr('style') + '">' + $(@).val() + '</div>')

    # обновить текущий список лейблов тикета на борде и в попапе
    $('.b-issue-labels', '.current-issue, .issue-modal').html(html_labels)

    # отправить на сервер набор лейблов
    $.get $(@).data('url'), { labels: labels }

  # скрыть тикет после успешной архивации
  $('.issue .archive').on 'ajax:success', (e, data) ->
    $(e.target).parent('.issue').remove() if data && data.archived

  # изменить тикет и открыть архивацию после успешного закрытия
  $('.issue .close').on 'ajax:success', (e, data) ->
    if (data && data.closed)
      $(e.target).parent('.issue').addClass('closed').removeClass('open')
      $(e.target).next('.archive').removeClass('hidden')
      $(e.target).remove()

  # пересчитать высоту борда в зависимости от высоты окна браузера
  resize_height()

$(window).resize ->
  return unless document.body.id == 'boards_show' & !resize_lock
  resize_lock = true
  setTimeout ->
      resize_height()
    , 400

# пересчитать высоту борда
resize_height = ->
  resize_lock = false

  height = $(window).height() - $('.l-menu').outerHeight(true) - $('.l-submenu').outerHeight(true)
  $('.board').height(height)
