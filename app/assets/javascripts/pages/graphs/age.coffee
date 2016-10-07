$(document).on 'turbolinks:load', (e) ->
  return unless document.body.id == 'age_index'
  new AgeChart($('.chart'))
