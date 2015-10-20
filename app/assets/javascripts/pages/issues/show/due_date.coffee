window.due_date = ->
  # раскрыть попап с календарем для установки крайней даты
  $('.set-due-date').click ->
    $('.issue-popup').hide()
    $('.overlay', '.issue-actions').show()

    $popup = $(@).parent().find('.issue-popup')
    $datepicker = $('.datepicker', $popup)
    $datepicker.datepicker({
      dateFormat: 'dd/mm/yy',
      onSelect: ->
        $popup.find('input.date').val($(@).val())
    })
    $datepicker.datepicker('setDate', new Date($(@).data('date')))
    $popup.show()

  # сохранение крайней даты
  $('.edit-due-date .save').click ->
    date = $('input.date').val()
    time = $('input.time').val()
    $.ajax
      url: $('.edit-due-date').data('url'),
      data: { due_date: "#{date} #{time}" },
      method: 'post',
      success: (date) ->
        $('.issue-popup').hide()
        $('.due-date').removeClass('none').html(date)
        # FIX : Extract method for find current issue number
        #number = $modal.find('.b-issue-modal').data('number')

