window.build_s3_image_url = (url, key) ->
  sanitize_key = encodeURIComponent(key)
  sanitize_key = sanitize_key.replace(/([(){}\[\]#+-.!])/g, "\\$1")
  "![#{key}](#{url}/#{sanitize_key})"

window.init_direct_upload = ($elements, url, form_data) ->
  $elements.each (i, elem) ->
    $fileInput = $(elem)
    $form = $($fileInput.parents('form:first')).first()
    $submitButton = $form.find('input[type="file"]')
    $textarea = $form.parents('.editable-form').find('textarea')
    $progress = $form.find('.progress')
    $info = $form.find('.info')

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
        $info.hide()
        $textarea.removeClass('dragenter')
        $form.parents('.upload').removeClass('dragenter')

      done: (e, data) ->
        key = $(data.jqXHR.responseXML).find('Key').text()
        image_url = window.build_s3_image_url(url, key)

        text = $textarea.val()
        $textarea.focus().val("").val("#{text}#{image_url}\n")

        $progress.hide()
        $submitButton.show()
        $info.show()

      fail: (e, data) ->
        $progress.hide()
        $info.show()
        $submitButton.show()

    $textarea.on 'dragenter', ->
      $textarea.addClass('dragenter')
      $form.parents('.upload').addClass('dragenter')

    $textarea.on 'dragleave', ->
      $textarea.removeClass('dragenter')
      $form.parents('.upload').removeClass('dragenter')
