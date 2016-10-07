$(document).on 'turbolinks:load', ->
  return unless document.body.id == 'boards_index'
  new Dashboard $('.b-dashboard')
