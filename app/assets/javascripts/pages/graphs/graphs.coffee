$(document).on 'turbolinks:load', ->
  $('.preference').on 'click', (e) ->
    $(@).parent().find('.preference-content').toggleClass('hidden')
