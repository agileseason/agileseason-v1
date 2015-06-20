resize_lock = false

$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'
  column_menu()
  new_issue_forms()
  $.initJsPathForInputs()

  # пересчитать высоту борда в зависимости от высоты окна браузера
  resize_height()

  # открыть модальное окно с issue по прямой сслыке
  #if location.hash
    #number = location.hash.match(/issue-number=(\d+)/)?[1]
    #show_issue_modal(number) if number

  #$('.issues').on 'click', '.issue.draggable', (e) ->
    #unless $(e.target).is('a, .button')
      #$(@).closest('.issue').addClass 'current-issue'
      #show_issue_modal($(@).data('number'))

  # открыть форму добавления тикета или колонки
  $('.new-issue, .new-column').click ->
    $(@).next().show()
    $('textarea', $(@).next()).first().focus()
    $(@).hide()

  # закрыть форму создания тикета или колонки
  $('.board-column').on 'click', '.cancel', ->
    $(@).closest('.inline-form').prev().show()
    $(@).closest('.inline-form').hide()
    false

  $('.issue-modal').on 'ajax:success', (e, data) ->
    #console.log 'modal ajax:success'
    number = $(@).find('.b-issue-modal').data('number')
    # FIX : Find reason what find return two element .b-assignee-container
    find_issue(number).find('.b-assignee-container').each ->
      $(@).html(data)
    $(@).find('.b-assignee-container').html(data)
    $(@).find('.b-assign .check').removeClass('octicon octicon-check')
    $('.check', $(e.target)).addClass('octicon octicon-check')
    $(@).find('.popup').hide() # скрытый эффект - закрывает все popup

  # раскрыть попап с календарем для установки крайней даты
  $('.board-column, .issue-modal').on 'click', '.set-due-date', ->
    $popup = $(@).parent().find('.popup')
    $datepicker = $('.datepicker', $popup)
    $datepicker.datepicker({
      dateFormat: 'dd/mm/yy',
      onSelect: ->
        $popup.find('.date input').val($(@).val())
    })
    $datepicker.datepicker('setDate', new Date($(@).data('date')))
    $popup.show()

  # сохранение крайней даты
  $('.board-column, .issue-modal').on 'click', '.edit-due-date .button.save', ->
    $modal = $(@).parents('.issue-modal')
    date = $modal.find('.date input').val()
    time = $modal.find('.time input').val()
    $.ajax
      url: $modal.find('.edit-due-date').data('url'),
      method: 'POST',
      data: { due_date: "#{date} #{time}" },
      success: (date) ->
        $modal.find('.popup').hide()
        $modal.find('.due-date').removeClass('none').html(date)
        # FIX : Extract method for find current issue number
        number = $modal.find('.b-issue-modal').data('number')
        find_issue(number).find('.due-date').removeClass('none').html(date)

  # раскрыть попап с пользователями для назначения
  $('.board-column, .issue-modal').on 'click', '.assignee', ->
    $(@).parent().find('.popup').show()

  # скрыть попап с пользователями для назначения
  $('.board-column, .issue-modal').on 'click', '.close-popup', ->
    $popup = $(@).closest('.popup')
    $popup.parent().find('.assignee').show()
    $popup.hide()

  # раскрыть попап с лейблами тикета
  $('.board-column, .issue-modal').on 'click', '.add-label', ->
    $(@).parent().prev().show()
    $(@).hide()

  # скрыть попап с лейблами тикета
  $('.board-column, .issue-modal').on 'click', '.close-popup', ->
    $(@).closest('.popup').next().find('.add-label').show()
    $(@).closest('.popup').hide()

  # изменить набор лейблов тикета
  $('.board-column, .issue-modal').on 'change', 'label input', ->
    labels = []
    html_labels = []
    $(@).parents('.labels-block').find('input:checked').each ->
      labels.push $(@).val()
      html_labels.push('<div class="label" style="' + $(@).parent().attr('style') + '">' + $(@).val() + '</div>')

    # обновить текущий список лейблов тикета на борде и в попапе
    $('.b-issue-labels', '.current-issue, .issue-modal').html(html_labels)

    # отправить на сервер набор лейблов
    $.post $(@).data('url'), { labels: labels }

  # скрыть тикет после архивации
  $('.issue .archive').on 'click', ->
    $(@).parent('.issue').addClass('hidden')
  # обновить WIP у колонки после архивации тикета
  $('.issue .archive').on 'ajax:success', (e, badge) ->
    window.update_wip_column(badge)

  # изменить тикет и открыть архивацию после успешного закрытия
  $('.board').on 'click', '.issue .close', ->
    $(@).parent('.issue').addClass('closed').removeClass('open')
    $(@).next('.archive').removeClass('hidden')
    $(@).remove()

$(window).resize ->
  return unless document.body.id == 'boards_show' & !resize_lock
  resize_lock = true
  setTimeout ->
      resize_height()
    , 400

show_issue_modal = (number) ->
  $issue_modal = $('.issue-modal')
  $modal_content = $('.modal-content', $issue_modal)
  $issue_modal.show()
  $modal_content.html('<div class="b-issue-modal" style="text-align: center;"><div class="b-preloader modal-preloader"></div></div>')

  $.ajax
    url: "/boards/#{$('.board').data('github_full_name')}/issues/#{number}",
    success: (html) ->
      $modal_content.html($(html)).trigger 'modal:load'
      location.hash = "#issue-number=#{number}"

# пересчитать высоту борда
resize_height = ->
  resize_lock = false

  height = $(window).height()# - $('.b-menu').outerHeight(true)
  $('.board').height(height)

column_menu = ->
  $('.board-column').on 'click', '.column-menu', ->
    $(@).addClass('active').prepend('<div class="overlay"></div>')
    $(@).find('.popup').show()

  $('.board-column .column-menu').on 'click', '.overlay', ->
    $(@).parent().find('.popup').hide()
    $(@).parent().removeClass 'active'
    $(@).remove()

  $('.column-menu .delete').bind 'ajax:success', (e, data) ->
    if data.result
      $(".board-column[data-column='#{data.id}']").hide()
    else
      alert(data.message)

find_issue = (number) ->
  $(".issue[data-number='#{number}']")

new_issue_forms = ->
  $('form.new_issue').on 'submit', ->
    $form = $(@)
    if $form.data('blocked')
      false
    else
      $form.data('blocked', true)

  $('form.new_issue').on 'ajax:success', (e, data) ->
    $form = $(@)
    $form.removeData('blocked')
    return if data == ''
    $form.find('.cancel').trigger('click') # закрываем форму
    $form.find('textarea').val('') # в данном случае нужно очищать поле ввода
    $issues = $('.issues', $form.closest('.board-column'))
    $issues.prepend(data)

window.update_wip_column = (badge) ->
  $("#column_#{badge.column_id}").find('.badge').replaceWith(badge.html)
