$(document).on 'page:change', ->
  $('.preference').on 'click', (e) ->
    $(@).parent().find('.preference-content').toggleClass('hidden')
