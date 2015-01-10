$(document).on 'page:change', ->
  $('.l-menu').on 'click', '.boards', ->
    $(@).addClass('active').prepend('<div class="overlay"></div>')
    $(@).find('.popover').show()

  $('.l-menu .boards').on 'click', '.overlay', ->
    $(@).parent().find('.popover').hide()
    $(@).parent().removeClass 'active'
    $(@).remove()
