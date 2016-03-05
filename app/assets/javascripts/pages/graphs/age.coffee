$(document).on 'page:change', (e) ->
  return unless document.body.id == 'age_index'
  $('.chart').render_chart()
