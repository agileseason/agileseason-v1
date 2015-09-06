$(document).on 'page:change', ->
  return unless document.body.id == 'settings_show'
  $.initJsPathForInputs()

  $('.columns li').click (e) ->
    if $(e.target).is('.octicon-gear') ||
        $(e.target).is('.columns li') ||
        $(e.target).is('.active-settings .autoassign')
      $('.other-settings', $(@).closest('li')).toggle()

  $('#board_name').blur ->
    $('input:submit', $(@).closest('form')).trigger 'click'

  $('.autoassign input').on 'change', ->
    $('.active-settings .autoassign', $(@).closest('li')).toggleClass 'active'

  $('.delete').on 'ajax:before', ->
    $(@).closest('li').fadeOut()
