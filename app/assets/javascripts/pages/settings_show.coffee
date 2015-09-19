$(document).on 'page:change', ->
  return unless document.body.id == 'settings_show'
  $('ul.columns li').each ->
    new ColumnsSettings $(@)

  $('.columns li').on 'click', (e) => toggle_column_settings $(e.target)

  $('#board_name').on 'blur', -> $($(@).closest('form')).submit()

  $('.iphone-button').on 'ajax:success', -> change_url $(@)

toggle_column_settings = ($target) ->
  if $target.is('.octicon-gear') ||
      $target.is('.columns li') ||
      $target.is('.active-settings .autoassign')
    $('.other-settings', $target.closest('li')).toggle()

change_url = ($button) ->
  href = $button.attr('href')

  if href.match /false/
    updated_href = href.replace 'false', 'true'
    $button.attr('href', updated_href)
    $button
      .removeClass 'true'
      .text('Private board')
      .closest('.action').next('.setting-label').text('Not visible to anyone.')

  else if href.match /true/
    updated_href = href.replace 'true', 'false'
    $button.attr('href', updated_href)

    $button
      .addClass 'true'
      .text('Public board')
      .closest('.action').next('.setting-label').text('Visible to anyone.')
