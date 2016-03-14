$(document).on 'page:change', (e) ->
  return unless document.body.id == 'frequency_index'
  new FrequencyChart($('.chart'))
