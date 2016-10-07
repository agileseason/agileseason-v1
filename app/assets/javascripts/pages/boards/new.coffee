$(document).on 'turbolinks:load', ->
  return unless document.body.id == 'boards_new'

$(document).on 'ready turbolinks:load', ->
  $('#board_type_boardskanbanboard').click()
  $('#board_type_boardsscrumboard').prop('disabled', true)
