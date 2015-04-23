window.init_direct_upload = ($elements, url, form_data) ->
  $elements.each (i, elem) ->
    fileInput = $(elem)
    $form = $(fileInput.parents('form:first')).first()
    $submitButton = $form.find('input[type="file"]')
    $textarea = $form.parents('.edit-form').find('textarea')
    $progress = $form.find('.progress')
    #progressBar = $('<div class=\'bar\'></div>')
    #barContainer = $('<div class=\'progress\'></div>').append(progressBar)
    #fileInput.after barContainer
    fileInput.fileupload
      fileInput: fileInput
      url: url
      type: 'POST'
      autoUpload: true
      formData: form_data
      paramName: 'file'
      dataType: 'XML'
      replaceFileInput: false
      progressall: (e, data) ->
        #progress = parseInt(data.loaded / data.total * 100, 10)
        #progressBar.css 'width', progress + '%'

      start: (e) ->
        #$submitButton.prop 'disabled', true
        $submitButton.hide()
        $progress.show()

      done: (e, data) ->
        #$submitButton.prop 'disabled', false
        #progressBar.text 'Uploading done'
        # extract key and generate URL from response
        key = $(data.jqXHR.responseXML).find('Key').text()
        image_url = "![#{key}](#{url}/#{key})"
        debugger
        $textarea.append("#{image_url}\n")
        $submitButton.show()
        $progress.hide()

      fail: (e, data) ->
        #$submitButton.prop 'disabled', false
        #progressBar.css('background', 'red').text 'Failed'
        $progress.hide()
        $submitButton.show()


$(document).on 'modal:load', '.b-issue-modal', ->
  return unless document.body.id == 'boards_show'

  url = $('.board').data('direct_post_url')
  form_data = $('.board').data('direct_post_form_data')
  window.init_direct_upload($('.directUpload').find('input:file'), url, form_data)
