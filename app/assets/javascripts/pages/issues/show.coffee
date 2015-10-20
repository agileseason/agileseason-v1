$(document).on 'ready page:load', ->
  return unless document.body.id == 'issues_show'
  comments()
  subscribe_issue_update()
  due_date()
  assignee()
  labels()

  $('.b-menu').click (e) ->
    # клик вне тикета делает переход к борду
    if $(e.target).is('.b-menu, .b-menu > ul')
      Turbolinks.visit($('.b-menu .boards a').attr('href'))

  $issue_modal = $('.b-issue-modal.js-can-update')

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
