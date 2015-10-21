$(document).on 'ready page:load', ->
  return unless document.body.id == 'issues_show'
  $issue_modal = $('.b-issue-modal.js-can-update')

  new Comments $('.comments-container')
  subscribe_issue_update()
  due_date()
  assignee()
  labels()
  file_drag_over()

  $('.b-menu').click (e) ->
    # клик вне тикета делает переход к борду
    if $(e.target).is('.b-menu, .b-menu > ul')
      Turbolinks.visit($('.b-menu .boards a').attr('href'))

  $issue_modal.on 'keydown', 'textarea', (e) ->
    if e.keyCode == 13 && (e.metaKey || e.ctrlKey)
      $(@.form).find('input:submit').click()
      $(@).blur()
      false

  # редактировать название тикета
  $('.issue-title', $issue_modal).click ->
    $title = $(@).closest('.title')
    $textarea = $('textarea', $title)

    $val = $textarea.val()
    $(@).data('initial-text': $(@).text())

    $title.addClass 'active'

    $textarea
      .height $(@).height()
      .focus()
      .val ''
      .val $val

  # сохранить по блюру название тикета
  $('.title textarea').blur ->
    $('.issue-title').text($(@).val())
    $('.title').removeClass 'active'
    $('.button', '.title').trigger 'click'

  $('.move-to-column li', $issue_modal).click ->
    $('.move-to-column li').removeClass 'active'
    $(@).addClass 'active'

  # кнопака «ready»
  $('.issue-actions').on 'ajax:before', '.is_ready', ->
    $(@).toggleClass 'active'

  $('.overlay', '.issue-actions').click ->
    $('.issue-popup', '.issue-actions').hide()
    $(@).hide()

  # закрыть тикет
  $('.button.issue-close').on 'click', (e) ->
    $('.b-issue-modal').
      removeClass('open').
      addClass('closed')

  # открыть снова тикет
  $('.button.issue-reopen').on 'click', (e) ->
    $('.b-issue-modal').
      removeClass('closed').
      addClass('open')

  # отправить тикет в архив
  $('.button.issue-archive').on 'click', (e) ->
    $('.b-issue-modal').
      removeClass('closed').
      addClass('archived')

  # отправить тикет из архива снова на борд
  $('.button.issue-unarchive').on 'click', (e) ->
    $('.b-issue-modal').
      removeClass('archived').
      addClass('closed')

file_drag_over = ->
  # перетаскивать картинку можно в любое место окна,
  # она загрузится в активное поле,
  # если нет формы с классом active, то загрузится в поле
  # добавления нового комментария
  $('.b-issue-modal').on 'dragenter', ->
    show_dragging()

  $(document).on 'mouseout', ->
    hide_dragging()

  $(document).on 'drop', ->
    hide_dragging()

show_dragging = ->
  $('.drag-n-drop-overlay').addClass 'active'

hide_dragging = ->
  $('.drag-n-drop-overlay').removeClass 'active'
