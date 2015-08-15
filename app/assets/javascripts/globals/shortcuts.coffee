$(document).keyup (e) ->
  # клик по esc
  if (e.keyCode == 27)
    if $('.comment-form.active').length
      # закрыть все активные формы
      $('.close-without-saving', '.comment-form.active').trigger 'click'

    if $('.simple_form.new_issue').is(':visible')
      # закрыть форму добавления тикета
      $('.simple_form.new_issue .cancel').trigger 'click'

    else if document.body.id == 'issues_show'
      # вернуться к борду
      Turbolinks.visit($('.b-menu .boards a').attr('href'))
