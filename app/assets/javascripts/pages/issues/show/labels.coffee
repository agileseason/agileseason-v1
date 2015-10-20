window.labels = ->
  # раскрыть попап с лейблами тикета
  $('.add-label').click ->
    #console.log 'open:labels'
    $('.issue-popup').hide()
    $('.overlay', '.issue-actions').show()

    $(@).parent().prev().show()

  # изменить набор лейблов тикета
  $('label input').on 'change', ->
    labels = []
    html_labels = []
    $(@).parents('.labels-block').find('input:checked').each ->
      labels.push $(@).val()
      html_labels.push('<div class="label" style="' + $(@).parent().attr('style') + '">' + $(@).val() + '</div>')

    # обновить текущий список лейблов тикета на странице
    $('.b-issue-labels').html(html_labels)

    # отправить на сервер набор лейблов
    $(@).closest('form').submit()
