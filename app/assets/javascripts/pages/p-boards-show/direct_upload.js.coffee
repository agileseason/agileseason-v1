window.init_direct_upload = ($elements, url, form_data) ->
  $elements.each (i, elem) ->
    $fileInput = $(elem)
    $form = $($fileInput.parents('form:first')).first()
    $submitButton = $form.find('input[type="file"]')
    $textarea = $form.parents('.edit-form').find('textarea')
    $progress = $form.find('.progress')

    $fileInput.fileupload
      fileInput: $fileInput
      url: url
      type: 'POST'
      autoUpload: true
      formData: form_data
      paramName: 'file'
      dataType: 'XML'
      replaceFileInput: false
      progressall: (e, data) ->
        #progress = parseInt(data.loaded / data.total * 100, 10)

      start: (e) ->
        $submitButton.hide()
        $progress.show()

      done: (e, data) ->
        key = $(data.jqXHR.responseXML).find('Key').text()
        image_url = "![#{key}](#{url}/#{key})"

        text = $textarea.val()
        $textarea.focus().val("").val("#{text}#{image_url}\n")

        $submitButton.show()
        $progress.hide()

      fail: (e, data) ->
        $progress.hide()
        $submitButton.show()


$(document).on 'modal:load', '.b-issue-modal', ->
  return unless document.body.id == 'boards_show'

  url = $('.board').data('direct_post_url')
  form_data = $('.board').data('direct_post_form_data')
  window.init_direct_upload($('.directUpload').find('input:file'), url, form_data)
