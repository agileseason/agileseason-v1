#= require jquery
#= require jquery-ui
#= require turbolinks
#= require_self
#= require application/counters

$(document).on 'turbolinks:load', ->
  return unless document.body.id == 'landing_index'

  $.get('/mixpanel_events/client_event', event: 'landing')
