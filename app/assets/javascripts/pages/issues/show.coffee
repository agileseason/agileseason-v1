$(document).on 'ready page:load', ->
  return unless document.body.id == 'issues_show'

  subscribe_issue_update()

  $('.b-menu').click (e) ->
    # клик вне тикета делает переход к борду
    if $(e.target).is('.b-menu, .b-menu > ul')
      Turbolinks.visit($('.b-menu .boards a').attr('href'))

  $('textarea').elastic()
  highlight_code()

  init_uploading $('input:file')

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

  # сабмит добавления комментария
  $('form.add-comment').on 'ajax:success', (event, data, status, xhr) ->
    $('.issue-comments').append(data)
    $('textarea', '.add-comment-form')
      .val ''
      .removeAttr 'style'

    highlight_code()

  $('.move-to-column li', $issue_modal).click ->
    $('.move-to-column li').removeClass 'active'
    $(@).addClass 'active'

  # кнопака «ready»
  $('.issue-actions').on 'ajax:success', '.is_ready', (e, data) ->
    if data.is_ready && data.is_ready == 'true'
      $(@).closest('.is_ready').addClass 'active'
      $(@).find('.issue_stat_is_ready input').val('false')

    else if data.is_ready && data.is_ready == 'false'
      $(@).closest('.is_ready').removeClass 'active'
      $(@).find('.issue_stat_is_ready input').val('true')

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

      init_uploading($('input:file'))
      #init_uploading()

      $parent.addClass 'current-comment'
      $('.comment-form', $parent).addClass 'active'

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

  # перетаскивать картинку можно в любое место окна,
  # она загрузится в активное поле,
  # если нет формы с классом active, то загрузится в поле
  # добавления нового комментария
  $('.b-issue-modal').on 'dragenter', ->
    show_dragging()

  $(document).on 'mouseout', ->
    hide_dragging()

  $(document).on 'drop', ->
    hide_dragging()

  $('.overlay', '.issue-actions').click ->
    $('.issue-popup', '.issue-actions').hide()
    $(@).hide()

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

  # раскрыть попап с пользователями для назначения
  $('.assignee').click ->
    $('.issue-popup').hide()
    $(@).parent().find('.issue-popup').show()

    $('.overlay', '.issue-actions').show()

  $('.b-assign .user').click (e) ->

    if $('.check', @).hasClass 'octicon octicon-check'
      $('.check', @).removeClass 'octicon octicon-check'
      $('.b-assignee', '.user-list').addClass 'hidden'

    else
      img_src = $(@).find('img').attr('src')
      $('img', '.user-list').attr('src', img_src)

      a_href = $(@).find('a').attr('href')
      a_title = $(@).find('.name').text()
      $('a', '.user-list')
        .attr('href', a_href)
        .attr('title', a_title)

      $('.b-assign .user .check').removeClass 'octicon octicon-check'

      $('.check', @).addClass 'octicon octicon-check'
      $('.b-assignee', '.user-list').removeClass 'hidden'

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

# private ###########################################################

highlight_code = ->
  $('pre code').each (i, block) ->
    hljs.highlightBlock block

update_by_checkbox = ($checkbox) ->
  event.stopPropagation()
  $comment_text = $checkbox.closest('.comment-text')

  initial_comment = $('textarea', $comment_text.parent()).val()
  checkbox_index = $checkbox.parents('.comment-text').find('input').index($checkbox)
  checkbox_value = if $checkbox.is(':checked') then '[x]' else '[ ]'

  update_comment =
    replaceNthMatch(initial_comment, /(\[(?:x|\s)\])/, checkbox_index + 1, checkbox_value)

  $('textarea', $comment_text.parent())
    .val(update_comment)

  $('form.edit-comment', $comment_text.parent())
    .trigger 'submit'

subscribe_issue_update = ->
  $issue = $('.b-issue-modal')
  return unless $issue.data('faye-on')
  return unless window.faye

  try
    window.faye.apply $issue.data('faye-channel'), $issue

    $issue.on 'faye:comment_create', (e, data) ->
      window.faye.updateProcessTime()
      $fetch_issue = $('.b-issue-modal')
      return unless $fetch_issue.data('number') == parseInt(data.number)
      $('.issue-comments').append(data.html)

  catch err
    console.log err

show_dragging = ->
  $('.drag-n-drop-overlay').addClass 'active'

hide_dragging = ->
  $('.drag-n-drop-overlay').removeClass 'active'
