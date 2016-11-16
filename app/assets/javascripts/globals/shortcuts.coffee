$(document).keydown (e) ->
  # Create issue
  if document.body.id == 'boards_show'
    # Char c or 1..9
    if (e.keyCode == 67 || (e.keyCode >= 49 && e.keyCode <= 57))
      return if e.shiftKey || e.ctrlKey || e.altKey || e.metaKey
      return if $('.issue-modal-container:visible').length > 0
      if (e.keyCode == 67)
        columnNumber = 1
      else
        columnNumber = e.keyCode - 48
      $(".column-shortcut-number-#{columnNumber} .issue-new").click()

  # Esc
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

    # Close activities
    else if $('.b-activities').hasClass 'active'
      $('.overlay', '.b-activities').trigger 'click'

    # Close search
    else if $('.search').hasClass 'active'
      $('.overlay', '.search').trigger 'click'

    # Close Issue modal
    else if document.body.id == 'issues_show'
      # вернуться к борду
      Turbolinks.visit($('.b-menu .boards a').attr('href'))

  else if (e.keyCode == 13)
    # Для textarea не переходим на новую строку.
    # Для input не игнорируем cmd+enter.
    # Пришлось вешать на body, т.к. если фокус немного сместится,
    # то в event.target будет уже body, а не поля ввода.
    if $('#issue-modal-new').is(':visible')
      $('#issue-modal-new').find('input:submit').click()
