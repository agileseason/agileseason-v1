resize_lock = false

$(document).on 'modal:load', '.b-issue-popup', ->
  $issue_popup = $(@)

  # открыть редактирование
  $('.editable .octicon-pencil', $issue_popup).on 'click', ->
    # скрыть открытые формы редактирования
    $('.edit-form .cancel').trigger 'click'

    $('.editable', $(@).closest('.edit')).hide()
    $('.edit-form', $(@).closest('.edit')).show()

  # закрыть редактирование по кнопке
  $('.edit-form .cancel', $issue_popup).on 'click', ->
    close_edit_issue_form($(@).parents('.edit'))

  # сабмит
  $('.edit-form button', $issue_popup).on 'click', ->
    new_content = $('.field', $(@).parents('.edit-form')).val()
    new_content = new_content.substr(0,1).toUpperCase() + new_content.substr(1)
    $(@).parents('.edit').find('.editable .edit-content').html(new_content)

    close_edit_issue_form($(@).parents('.edit'))

    if $('.editable', $(@).parents('.edit')).hasClass 'description'
      $.get $(@).attr('href'), { body: new_content }

    else if $('.editable', $(@).parents('.edit')).hasClass 'title'
      $('.issue-name', '.current-issue').html(new_content)
      $.get $(@).attr('href'), { title: new_content }

$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  # показать прелоадер перед попапом тикета
  $('.issue-name').click ->
    $('.l-preloader').show()

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
  $('.board-column, .l-modal').on 'click', '.add-label', ->
    $(@).parent().prev().show()
    $(@).hide()

  # скрыть попап с лейблами тикета
  $('.board-column, .l-modal').on 'click', '.close-popup', ->
    $(@).closest('.popup').next().find('.add-label').show()
    $(@).closest('.popup').hide()

  # изменить набор лейблов тикета
  $('.board-column, .l-modal').on 'change', 'label input', ->
    labels = []
    html_labels = []
    $(@).parents('.labels-block').find('input:checked').each ->
      labels.push $(@).val()
      html_labels.push('<div class="label" style="' + $(@).parent().attr('style') + '">' + $(@).val() + '</div>')
    labels.push '[' + $('.current-issue').closest('.board-column').data('column') + '] ' + $('.current-issue').closest('.board-column').data('column-name')

    # обновить текущий список лейблов тикета на борде и в попапе
    $('.b-issue-labels', '.current-issue, .l-modal').html(html_labels)

    # отправить на сервер набор лейблов
    $.get $(@).data('url'), { labels: labels }

  # пересчитать высоту борда в зависимости от высоты окна браузера
  resize_height()

$(window).resize ->
  return unless document.body.id == 'boards_show' & !resize_lock
  resize_lock = true
  setTimeout ->
      # пересчитать высоту борда при ресайзе
      resize_height()
    , 400

resize_height = ->
  resize_lock = false

  height = $(window).height() - $('.l-menu').outerHeight(true) - $('.l-submenu').outerHeight(true)
  $('.board').height(height)

close_edit_issue_form = ($parent_node) ->
  $('.editable', $parent_node).show()
  $('.edit-form', $parent_node).hide()
