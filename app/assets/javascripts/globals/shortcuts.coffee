$(document).keydown (e) ->
  # клик по esc
  if (e.keyCode == 27)
    if $('.comment-form.active').length
      # закрыть все активные формы
      $('.close-without-saving', '.comment-form.active').trigger 'click'

    $modal = $('.close-modal:visible')
    if $modal.length
      $escapables = $('.escapeble:visible')
      if $escapables.length
        $escapables[0].click()
      else
        $modal.trigger('click')

    if $('.simple_form.new_issue').is(':visible')
      # закрыть форму добавления тикета
      $('.simple_form.new_issue .cancel').trigger 'click'

    # закрыть лог событий
    else if $('.b-activities').hasClass 'active'
      $('.overlay', '.b-activities').trigger 'click'

    # закрыть поиск
    else if $('.search').hasClass 'active'
      $('.overlay', '.search').trigger 'click'

    else if document.body.id == 'issues_show'
      # вернуться к борду
      Turbolinks.visit($('.b-menu .boards a').attr('href'))

  else if (e.keyCode == 13)
    # Для textarea не переходим на новую строку.
    # Для input не игнорируем cmd+enter.
    # Пришлось вешать на body, т.к. если фокус немного сместится,
    # то в event.target будет уже body, а не поля ввода.
    if $('.simple_form.new_issue').is(':visible')
      $('.simple_form.new_issue').find('input:submit').click()
      false
