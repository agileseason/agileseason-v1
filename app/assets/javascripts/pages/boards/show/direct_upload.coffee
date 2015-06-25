window.build_s3_image_url = (url, key) ->
  sanitize_key = encodeURIComponent(key)
  sanitize_key = sanitize_key.replace(/([(){}\[\]#+-.!])/g, "\\$1")
  "![#{key}](#{url}/#{sanitize_key})"

window.init_direct_upload = ($elements, url, form_data) ->
  $elements.each (i, elem) ->
    $input = $(elem)
    $upload_form = $input.closest('form')
    $parent = $input.closest('.b-editable-form')
    #$submitButton = $upload_form.find('input[type="file"]')

    $textarea = $('textarea', $parent)
    $progress = $('.progress', $upload_form)
    $info = $('.info', $upload_form)

    $input.fileupload
      fileInput: $input
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
        #$submitButton.hide()
        $current_uploading = $('.current-uploading')

        $('.progress', $current_uploading).show()
        $('.info', $current_uploading).hide()
        $('textarea', $current_uploading).removeClass('dragenter')
        $('.upload', $current_uploading).removeClass('dragenter')

      done: (e, data) ->
        $current_uploading = $('.current-uploading')

        key = $(data.jqXHR.responseXML).find('Key').text()
        image_url = window.build_s3_image_url(url, key)

        text = $('textarea', $current_uploading).val()
        $('textarea', $current_uploading)
          .focus()
          .val("").val("#{text}#{image_url}\n")

        $('.progress', $current_uploading).hide()
        #$submitButton.show()
        $('.info', $current_uploading).show()

        $('.b-editable-form').removeClass 'current-uploading'

      fail: (e, data) ->
        $current_uploading = $('.current-uploading')

        $('.progress', $current_uploading).hide()
        $('.info', $current_uploading).show()

        $('.b-editable-form').removeClass 'current-uploading'
        #$submitButton.show()

    $textarea.on 'dragenter', ->
      $textarea.addClass('dragenter')
      $upload_form.parents('.upload').addClass('dragenter')

    $textarea.on 'dragleave', ->
      $textarea.removeClass('dragenter')
      $upload_form.parents('.upload').removeClass('dragenter')
