(($) ->
  $.fn.extend js_patch: ->
    @each ->
      $input = $(@)

      if $input.is ':checkbox'
        $input.on 'change', -> toggle_check $input

      $input.on 'blur', -> submit_input $input

    submit_input = ($input) ->
      $.ajax
        url: $input.data 'url'
        method: 'PATCH'
        data:
          name: $input.attr 'name'
          value: $input.val()
        success: (data) ->
          Turbolinks.visit(data.redirect_url) if data && data.redirect_url

    toggle_check = ($input) ->
      $input
        .val $input.prop 'checked'
        .blur()
) jQuery

