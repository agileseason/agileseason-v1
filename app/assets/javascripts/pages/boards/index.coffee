$(document).on 'page:change', ->
  return unless document.body.id == 'boards_index'

  $('.b-dashboard').trigger 'wizard:load'
