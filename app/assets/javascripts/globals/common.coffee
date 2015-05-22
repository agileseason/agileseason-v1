$ ->
  Turbolinks.enableProgressBar true

$(document).on 'left:menu:show', ->
  $('.overlay', '.left-menu').click ->
    $('.left-menu').removeClass 'show'

$(document).on 'page:change', ->
  $('.left-menu-link').click ->
    $('.left-menu').addClass 'show'
    $(document).trigger 'left:menu:show'

  $('.l-menu .boards').click (e) ->
    return if $(e.target).is('.current-board-link')

    if $(e.target).is('.overlay', '.l-menu .boards')
      $(@).find('.popup').hide()
      $(@).removeClass 'active'
      $(@).find('.overlay').remove()

    else
      $(@).addClass('active').prepend('<div class="overlay"></div>')
      $(@).find('.popup').show()
