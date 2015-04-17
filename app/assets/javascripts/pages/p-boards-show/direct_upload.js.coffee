$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  url = $('.board').data('direct_post_url')
  form_data = $('.board').data('direct_post_form_data')

  $ ->
    $('.directUpload').find('input:file').each (i, elem) ->
      fileInput = $(elem)
      form = $(fileInput.parents('form:first'))
      submitButton = form.find('input[type="submit"]')
      progressBar = $('<div class=\'bar\'></div>')
      barContainer = $('<div class=\'progress\'></div>').append(progressBar)
      fileInput.after barContainer
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
          progress = parseInt(data.loaded / data.total * 100, 10)
          progressBar.css 'width', progress + '%'
          return
        start: (e) ->
          submitButton.prop 'disabled', true
          progressBar.css('background', 'green').css('display', 'block').css('width', '0%').text 'Loading...'
          return
        done: (e, data) ->
          submitButton.prop 'disabled', false
          progressBar.text 'Uploading done'
          # extract key and generate URL from response
          key = $(data.jqXHR.responseXML).find('Key').text()
          image_url = "![#{key}](#{url}/#{key})\n"
          #form.parents('.issue-description').find('textarea').append("![#{key}](#{image_url})\n")
          progressBar.after("<p>#{image_url}</p>")
          return
        fail: (e, data) ->
          submitButton.prop 'disabled', false
          progressBar.css('background', 'red').text 'Failed'
          return
      return
    return
