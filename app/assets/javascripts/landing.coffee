#= require jquery
#= require jquery-ui
#= require turbolinks
#= require_self

$(document).on 'page:change', ->
  return unless document.body.id == 'landing_index'

  $.get('/mixpanel_events/client_event', event: 'landing')

# TODO Remove this duplication, see application.coffee
# Turbolinks and mentrika.yandex.ru
$(document).on 'page:before-change', =>
  @turbolinks_referer = location.href
$(document).on 'page:load', =>
  if @turbolinks_referer
    if @yaCounter27976815
      @yaCounter27976815.hit location.href, $('title').html(), @turbolinks_referer
