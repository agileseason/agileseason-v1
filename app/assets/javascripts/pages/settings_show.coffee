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

  $('.iphone-button').on 'ajax:success', ->
    console.log 123
    change_url $(@)

change_url = ($button) ->
  href = $button.attr('href')

  if href.match /false/
    updated_href = href.replace 'false', 'true'
    $button.attr('href', updated_href)
    $button
      .removeClass 'true'
      .text('Private board')

  else if href.match /true/
    updated_href = href.replace 'true', 'false'
    $button.attr('href', updated_href)

    $button
      .addClass 'true'
      .text('Public board')
