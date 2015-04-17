$(document).on 'page:change', ->
  return unless document.body.id == 'awstest_index'

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
        url: $('#aws_test').data('direct_url')
        type: 'POST'
        autoUpload: true
        formData: $('#aws_test').data('direct_form_data')
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
          url = $('#aws_test').data('direct_url') + key
          $('textarea').append '![' + key + '](' + url + ')\n'
          $('.keys').append url
          return
        fail: (e, data) ->
          submitButton.prop 'disabled', false
          progressBar.css('background', 'red').text 'Failed'
          return
      return
    return
