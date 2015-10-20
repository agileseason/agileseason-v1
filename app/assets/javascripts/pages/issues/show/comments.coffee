window.comments = ->
  fetch_comments()
  $('textarea').elastic()
  highlight_code()
  init_uploading $('input:file')

  # сабмит добавления комментария
  $('form.add-comment').on 'ajax:success', (event, data, status, xhr) ->
    $('.issue-comments').append(data)
    $('textarea', '.add-comment-form')
      .val ''
      .removeAttr 'style'
    highlight_code()

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


fetch_comments = ->
  $container = $('.issue-comments')
  return if $container.data('comments') == 0

  $.ajax
    url: $container.data('url')
    success: (html) ->
      $container.html(html)

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

show_dragging = ->
  $('.drag-n-drop-overlay').addClass 'active'

hide_dragging = ->
  $('.drag-n-drop-overlay').removeClass 'active'
