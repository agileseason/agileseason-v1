$(document).on 'turbolinks:load', (e) ->
  return unless document.body.id == 'frequency_index'
  new FrequencyChart($('.chart'))
