$(document).keyup (e) ->
  # клик по esc
  if (e.keyCode == 27)
    if $('.comment-form.active').length
      # закрыть все активные формы
      $('.close-without-saving', '.comment-form.active').trigger 'click'
    else
      # вернуться к борду
      Turbolinks.visit($('.b-menu .boards a').attr('href'))

$(document).on 'page:change', ->
  return unless document.body.id == 'issues_show'

  $('textarea').elastic()
  highlight_code()
  init_uploading()

  # редактировать название тикета
  $('.issue-title').click ->
    $title = $(@).closest('.title')
    $textarea = $('textarea', $title)

    $val = $textarea.val()
    $(@).data('initial-text': $(@).text())

    $title.addClass 'active'

    $textarea.focus().val('').val($val)

  # сохранить по блюру название тикета
  $('.title textarea').blur ->
    $('.issue-title').text($(@).val())
    $('.title').removeClass 'active'
    $('.button', '.title').trigger 'click'

  # сабмит добавления комментария
  $('form.add-comment').on 'ajax:success', (event, data, status, xhr) ->
    $('.issue-comments').append(data)
    $('textarea', '.add-comment-form')
      .val ''
      .removeAttr 'style'

    highlight_code()

  $('.move-to-column li').click ->
    $('.move-to-column li').removeClass 'active'
    $(@).addClass 'active'

  #$('.preview').click ->
    #string = $('textarea', $(@).closest('form')).val()

    #$.post $(@).data('url'), string: string, (markdown) =>
      #$(@).closest('form').addClass('preview-mode')
      #$('.preview-textarea', $(@).closest('form')).html(markdown)

  #$('.write').click ->
    #$(@).closest('form').removeClass('preview-mode')

  $('.issue-comments, .add-comment-form')
    # указываю, в какую форму загружать картинку
    .on 'click', '.upload a', ->
      $('.b-editable-form').removeClass 'current-uploading'
      $(@).closest('.b-editable-form').addClass 'current-uploading'

    # не отправлять пустой комментарий при добавлении и редактировании
    .on 'click', 'input:submit', (e) ->
      e.preventDefault()
      $textarea = $(@).closest('form').find('textarea')
      if $textarea.val().trim() == ''
        $textarea.val('').focus()
        return

      else
        $textarea.closest('form').submit()

  $('.issue-comments')
    # удалить комментарий
    .on 'click', '.delete', ->
      if window.confirm('Delete comment?')
        $.ajax
          url: $(@).data('url')
          method: 'delete'
        $(@).closest('.issue-comment').remove()

    # открыть форму редактирования комментария
    .on 'click', '.edit', ->
      $parent = $(@).closest('.comment-body ')

      $parent.addClass 'current-comment'
      $('.comment-form', $parent).addClass 'active'

      $comment_height = $('.comment-text', $parent).height()
      $('textarea', $parent).css('height', $comment_height)

      $initial_value = $('textarea', $parent).val()
      $('textarea', $parent).data('initial-value': $initial_value)

      $('textarea').elastic()

    # закрыть комментарий без сохранения
    .on 'click', '.close-without-saving', ->
      $parent = $(@).closest('.comment-body ')

      $('textarea', $parent).val($('textarea', $parent).data('initial-value'))

      $parent.removeClass 'current-comment'
      $('.comment-form', $parent).removeClass 'active'

    # сабмит формы редактирования комментария
    .on 'ajax:success', 'form.edit-comment', (event, data, status, xhr) ->
      $current_comment = $(@).closest('.issue-comment')
      $current_comment.after(data)
      $current_comment.remove()

      highlight_code()

    # сохранить чекбоксы в комментарии
    .on 'click', '.task', ->
      update_by_checkbox $(@)

    #console.log 'modal ajax:success'
    #number = $(@).find('.b-issue-modal').data('number')
    ## FIX : Find reason what find return two element .b-assignee-container
    #find_issue(number).find('.b-assignee-container').each ->
      #$(@).html(data)
    #$(@).find('.b-assignee-container').html(data)
    #$(@).find('.b-assign .check').removeClass('octicon octicon-check')
    #$('.check', $(e.target)).addClass('octicon octicon-check')
    #$(@).find('.popup').hide() # скрытый эффект - закрывает все popup

  # раскрыть попап с календарем для установки крайней даты
  $('.set-due-date').click ->
    $popup = $(@).parent().find('.popup')
    $datepicker = $('.datepicker', $popup)
    $datepicker.datepicker({
      dateFormat: 'dd/mm/yyyy',
      onSelect: ->
        $popup.find('.date input').val($(@).val())
    })
    $datepicker.datepicker('setDate', new Date($(@).data('date')))
    $popup.show()

  # сохранение крайней даты
  $('.edit-due-date .button.save').click ->
    date = $('.date input').val()
    time = $('.time input').val()
    $.ajax
      url: $('.edit-due-date').data('url'),
      data: { due_date: "#{date} #{time}" },
      method: 'post',
      success: (date) ->
        debugger
        $('.popup').hide()
        $('.due-date').removeClass('none').html(date)
        # FIX : Extract method for find current issue number
        #number = $modal.find('.b-issue-modal').data('number')
        # FIX : Find reason what find return two element .due-date
        #find_issue(number).find('.due-date').each ->
          #$(@).removeClass('none').html(date)

  # раскрыть попап с пользователями для назначения
  $('.assignee').click ->
    $(@).parent().find('.popup').show()

  # скрыть попап с пользователями для назначения
  $('.close-popup').click ->
    $popup = $(@).closest('.popup')
    $popup.parent().find('.assignee').show()
    $popup.hide()


  $('.b-assign .user').click (e) ->
    $('img', '.user-list').attr('src', $(@).find('img').attr('src'))
    $('a', '.user-list')
      .attr('href', $(@).find('a').attr('href'))
      .attr('title', $(@).find('.name').text())
    $('.check', @).addClass 'octicon octicon-check'
    $('.close-popup', $(@).closest('.popup')).trigger 'click'
    $('.b-assignee', '.user-list').removeClass 'hidden'

  # раскрыть попап с лейблами тикета
  $('.add-label').click ->
    console.log 'open:labels'
    $(@).parent().prev().show()
    $(@).hide()

  # скрыть попап с лейблами тикета
  $('.close-popup').click ->
    $(@).closest('.popup').next().find('.add-label').show()
    $(@).closest('.popup').hide()

  # изменить набор лейблов тикета
  $('label input').on 'change', ->
    labels = []
    html_labels = []
    $(@).parents('.labels-block').find('input:checked').each ->
      labels.push $(@).val()
      html_labels.push('<div class="label" style="' + $(@).parent().attr('style') + '">' + $(@).val() + '</div>')

    # обновить текущий список лейблов тикета на борде и в попапе
    $('.b-issue-labels').html(html_labels)

    $(@).closest('form').submit()
    # отправить на сервер набор лейблов
    #$.post $(@).data('url'), { labels: labels }

# private ###########################################################

highlight_code = ->
  $('pre code').each (i, block) ->
    hljs.highlightBlock block

init_uploading = ->
  url = $('.b-issue-modal').data('direct_post_url')
  form_data = $('.b-issue-modal').data('direct_post_form_data')
  window.init_direct_upload($('input:file'), url, form_data)

find_issue = (number) ->
  $(".issue[data-number='#{number}']")

update_by_checkbox = ($checkbox) ->
  event.stopPropagation()
  $comment_text = $checkbox.closest('.comment-text')

  checkbox_index = $checkbox.parent().children('input').index($checkbox) # because of <br><br>
  checkbox_value = $checkbox.is(':checked')

  initial_comment = $('textarea', $comment_text.parent()).val()
  update_comment =
    replaceNthMatch(initial_comment, /(\[(?:x|\s)\])/, checkbox_index + 1, if checkbox_value then '[x]' else '[ ]')

  $('textarea', $comment_text.parent())
    .val(update_comment)

  $('form.edit-comment', $comment_text.parent())
    .trigger 'submit'
