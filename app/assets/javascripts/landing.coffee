#= require jquery
#= require jquery-ui

$(document).on 'page:change', ->
  return unless document.body.id == 'landing_index'

  $.post('/mixpanel/client_event', event: 'landing')
