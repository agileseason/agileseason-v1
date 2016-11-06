# TODO: Remove after refactoring
class @NewIssueForm extends View
  initialize: ->
    @$form_content = @$('.create-issue')
    @$form = @$('form.new_issue')
    @$textarea = $('textarea', @$form)

    @$('.new-issue').on 'click', @_show_form
    $('.cancel', @$form).on 'click', @_close_form
    @$form_content.on 'click', @_close_by_overlay
    @$textarea.elastic()
    @$form.on 'submit', @_submit_form
    @$form.on 'ajax:success', @_after_submit

  _close_by_overlay: (e) =>
    if $(e.target).is '.create-issue'
      $(e.target).hide()
      false

  _close_form: =>
    @$form_content.hide()
    false

  _show_form: =>
    @$form_content.show()
    @$textarea.focus()

  _after_submit: (e, data) =>
    @$form.removeData 'blocked'
    return if data == ''

    @$textarea.val '' # очистить поле ввода
    $('label input', @$form).prop 'checked', false
    $('.cancel', @$form).click()

    @$('.issues').prepend data

  _submit_form: =>
    if @$form.data 'blocked'
      false
    else
      @$form.data 'blocked', true
