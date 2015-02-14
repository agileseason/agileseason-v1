resize_lock = false

$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  $('.show-issue-modal').on 'click', ->
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

  # открыть форму добавления тикета
  $('.new-issue').click ->
    $(@).next().show()
    $('#issue_title', $(@).next()).focus()
    $(@).hide()

  # закрыть форму тикета
  $('.board-column').on 'click', '.cancel', ->
    $(@).closest('.new-issue-form').prev().show()
    $(@).closest('.new-issue-form').hide()
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
    labels.push '[' + $('.current-issue').closest('.board-column').data('column') + '] ' + $('.current-issue').closest('.board-column').data('column-name')

    # обновить текущий список лейблов тикета на борде и в попапе
    $('.b-issue-labels', '.current-issue, .issue-modal').html(html_labels)

    # отправить на сервер набор лейблов
    $.get $(@).data('url'), { labels: labels }

  # скрыть тикет после успешной архивации
  $('.issue .archive').on 'ajax:success', (e, data) ->
    $(e.target).parent('.issue').remove() if data && data.archived

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
