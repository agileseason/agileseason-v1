$(document).on 'page:change', ->
  return unless document.body.id == 'boards_index'
  new Dashboard $('.b-dashboard')
