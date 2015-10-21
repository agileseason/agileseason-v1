class @Comments extends View
  initialize: ->
    @$comments = @$('.issue-comments')
    @$textarea = @$('textarea')
    @$add_comment_form = @$('form.add-comment')

    @_render_comments()
    @$textarea.elastic()
    init_uploading $('input:file')

    @$add_comment_form.on 'ajax:success', (e, data) => @_append_new_comment

    @$('.issue-comments, .add-comment-form')
      .on 'click', '.upload a', @_current_upload
      .on 'click', 'input:submit', @_validate_textarea

    @$comments
      .on 'click', '.delete', @_delete_comment
      .on 'click', '.edit', @_open_edit_form
      .on 'click', '.close-without-saving', @_close_without_saving
      .on 'ajax:success', 'form.edit-comment', (e, data) => @_submit_edit_form(e, data)
      .on 'click', '.task', @_update_by_checkbox

  _append_new_comment: (e, data) =>
    @$comments.append data
    $('textarea', @$add_comment_form)
      .val ''
      .removeAttr 'style'
    @_highlight_code()

  _validate_textarea: (e) =>
    e.preventDefault()
    $textarea = $(e.target).closest('form').find('textarea')
    if $textarea.val().trim() == ''
      $textarea.val('').focus()
      return
    else
      $textarea.closest('form').submit()

  _current_upload: (e) =>
    @$('.b-editable-form').removeClass 'current-uploading'
    $(e.target).closest('.b-editable-form').addClass 'current-uploading'

  _submit_edit_form: (e, data) =>
    $current_comment = $(e.target).closest('.issue-comment')
    $current_comment.after data
    $current_comment.remove()
    @_highlight_code()

  _close_without_saving: (e) =>
    $parent = $(e.target).closest('.comment-body ')
    initial_value = $('textarea', $parent).data 'initial-value'

    $('textarea', $parent).val initial_value
    $parent.removeClass 'current-comment'
    $('.comment-form', $parent).removeClass 'active'

  _open_edit_form: (e) =>
    $parent = $(e.target).closest('.comment-body ')

    init_uploading $('input:file')

    $parent.addClass 'current-comment'
    $('.comment-form', $parent).addClass 'active'

    $initial_value = $('textarea', $parent).val()
    $('textarea', $parent).data('initial-value': $initial_value)

    @$('textarea').elastic()

  _delete_comment: (e) =>
    if window.confirm('Delete comment?')
      $.ajax
        url: $(e.target).data 'url'
        method: 'delete'
      $(e.target).closest('.issue-comment').remove()

  _highlight_code: =>
    @$('pre code').each (i, block) ->
      hljs.highlightBlock block

  _update_by_checkbox: (e) =>
    e.stopPropagation()
    $checkbox = $(e.target)
    $comment_text = $checkbox.closest('.comment-text')

    @_update_comment($checkbox, $('textarea', $comment_text.parent()))
    $('form.edit-comment', $comment_text.parent()).trigger 'submit'

  _update_comment: ($checkbox, $textarea) =>
    initial_comment = $textarea.val()
    checkbox_index = $checkbox.parents('.comment-text').find('input').index($checkbox)
    checkbox_value = if $checkbox.is(':checked') then '[x]' else '[ ]'
    update_comment =
      replaceNthMatch(initial_comment, /(\[(?:x|\s)\])/, checkbox_index + 1, checkbox_value)

    $textarea.val update_comment

  _render_comments: =>
    return if @$comments.data('comments') == 0
    $.ajax
      url: @$comments.data 'url'
      success: (html) =>
        @$comments.html html
        @_highlight_code()
