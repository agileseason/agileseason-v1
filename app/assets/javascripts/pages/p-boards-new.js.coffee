$(document).on 'page:change', ->
  return unless document.body.id == 'boards_new'

$(document).on 'ready page:load', ->
  $('#board_type_boardskanbanboard').click()
  $('#board_type_boardsscrumboard').prop('disabled', true);
