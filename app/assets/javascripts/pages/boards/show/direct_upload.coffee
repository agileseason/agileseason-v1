window.build_s3_image_url = (url, key) ->
  sanitize_key = encodeURIComponent(key)
  sanitize_key = sanitize_key.replace(/([(){}\[\]#+-.!])/g, "\\$1")
  "![#{key}](#{url}/#{sanitize_key})"

window.init_uploading = ($input) ->
  url = $('.b-issue-modal').data('direct_post_url')
  form_data = $('.b-issue-modal').data('direct_post_form_data')

  $input.fileupload
    fileInput: $input
    url: url
    type: 'POST'
    autoUpload: true
    formData: form_data
    paramName: 'file'
    dataType: 'XML'
    replaceFileInput: false

    start: (e) ->
      return if not_current_form($(e.target))
      $('.progress', $(@).closest('form')).show()
      $('.info', $(@).closest('form')).hide()
      $('textarea', $(@).closest('.b-editable-form')).removeClass('dragenter')
      $('.upload', $(@).closest('.b-editable-form')).removeClass('dragenter')

    done: (e, data) ->
      return if not_current_form($(e.target))
      key = $(data.jqXHR.responseXML).find('Key').text()
      image_url = window.build_s3_image_url(url, key)

      text = $('textarea', $(@).closest('.b-editable-form')).val()
      $('textarea', $(@).closest('.b-editable-form')).focus().val("").val("#{text}#{image_url}\n")

      $('.progress', $(@).closest('form')).hide()
      $('.info', $(@).closest('form')).show()

    fail: (e, data) ->
      return if not_current_form($(e.target))
      $('.progress', $(@).closest('form')).hide()
      $('.info', $(@).closest('form')).show()

not_current_form = ($input) ->
  (!$input.closest('.b-editable-form.active').length && !$input.closest('.add-comment-form').length) ||
  ($input.closest('.add-comment-form').length && $('.b-editable-form.active').length)
