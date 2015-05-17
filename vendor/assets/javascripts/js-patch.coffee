window.jQuery.initJsPathForInputs = ->
  $('input.js-patch').on 'blur', (e) ->
    $input = $(@)
    $.ajax
      url: $input.data('url')
      method: 'PATCH'
      data: {
        name: $input.attr('name')
        value: $input.val()
      }
      success: (data) ->
        Turbolinks.visit(data.redirect_url) if data && data.redirect_url
