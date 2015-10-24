@actions = ->
  labels()
  assignee()
  due_date()
  close_open_issue()
  archive()
  ready_to_next_stage()

labels = ->
  # изменить набор лейблов тикета
  $('label input').on 'change', ->
    labels = []
    html_labels = []
    $(@).parents('.labels-block').find('input:checked').each ->
      labels.push $(@).val()
      style = $(@).parent().attr('style')
      html = "<div class='label' style='#{style}'>#{$(@).val()}</div>"
      html_labels.push html

    # обновить текущий список лейблов тикета на странице
    $('.b-issue-labels').html html_labels

    # отправить на сервер набор лейблов
    $(@).closest('form').submit()

assignee = ->
  $('.b-assign .user').on 'click', (e) ->
    if $('.check', @).hasClass 'octicon octicon-check'
      $('.check', @).removeClass 'octicon octicon-check'
      $('.b-assignee', '.user-list').addClass 'hidden'

    else
      img_src = $(@).find('img').attr('src')
      $('img', '.user-list').attr('src', img_src)

      a_href = $(@).attr('href')
      a_title = $(@).find('.name').text()
      $('a', '.user-list')
        .attr('href', a_href)
        .attr('title', a_title)

      $('.b-assign .user .check').removeClass 'octicon octicon-check'

      $('.check', @).addClass 'octicon octicon-check'
      $('.b-assignee', '.user-list').removeClass 'hidden'

due_date = ->
  $('.set-due-date').click ->
    $popup = $(@).parent().find('.issue-popup')
    $datepicker = $('.datepicker', $popup)
    $datepicker.datepicker({
      dateFormat: 'dd/mm/yy',
      onSelect: ->
        $popup.find('input.date').val($(@).val())
    })
    $datepicker.datepicker('setDate', new Date($(@).data('date')))

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

close_open_issue = ->
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

archive = ->
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

ready_to_next_stage = ->
  # кнопака «ready»
  $('.issue-actions').on 'ajax:before', '.is_ready', ->
    $(@).toggleClass 'active'
