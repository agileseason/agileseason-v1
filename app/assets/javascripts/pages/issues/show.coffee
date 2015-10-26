$(document).on 'ready page:load', ->
  return unless document.body.id == 'issues_show'
  $issue_container = $('.b-issue-modal.js-can-update')

  new Comments $('.comments-container')
  new IssueTitle $('.title')
  subscribe_issue_update()
  file_drag_over()
  actions() # actions.coffee

  $('.b-menu').click (e) -> # клик вне тикета делает переход к борду
    if $(e.target).is('.b-menu, .b-menu > ul')
      Turbolinks.visit($('.b-menu .boards a').attr('href'))

  $issue_container.on 'keydown', 'textarea', (e) ->
    if e.keyCode == 13 && (e.metaKey || e.ctrlKey)
      $(@.form).find('input:submit').click()
      $(@).blur()
      false

  $('.move-to-column li', $issue_container).click ->
    $('.move-to-column li').removeClass 'active'
    $(@).addClass 'active'

file_drag_over = ->
  # перетаскивать картинку можно в любое место окна,
  # она загрузится в активное поле,
  # если нет формы с классом active, то загрузится в поле
  # добавления нового комментария
  $('.b-issue-modal').on 'dragenter', ->
    $('.drag-n-drop-overlay').addClass 'active'

  $('body').on 'mouseout', ->
    $('.drag-n-drop-overlay').removeClass 'active'

  $('body').on 'drop', ->
    $('.drag-n-drop-overlay').removeClass 'active'
