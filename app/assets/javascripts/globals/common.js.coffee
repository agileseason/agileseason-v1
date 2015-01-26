$(document).on 'page:change', ->
  $('.l-menu').on 'click', '.boards', ->
    $(@).addClass('active').prepend('<div class="overlay"></div>')
    $(@).find('.popup').show()

  $('.l-menu .boards').on 'click', '.overlay', ->
    $(@).parent().find('.popup').hide()
    $(@).parent().removeClass 'active'
    $(@).remove()

  $('.notice .close').on 'click', ->
    $(@).parent('.notice').remove()
