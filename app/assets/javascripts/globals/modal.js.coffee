$(document).on 'ajax:success', (e, html) =>
  $('.l-preloader').hide()
  if $(e.target).data 'modal'
    $('.modal-content').html html
    $('.l-modal').fadeIn 300
    #$('.modal-inner').css('top', $(window).scrollTop() + 100 )

    $('.modal-content').children().trigger 'modal:load'

$(document).on 'page:change', ->
  $('.l-modal').on 'click', '.modal-close, .overlay', ->
    $modal = $(@).closest('.l-modal')
    $content = $('> .modal-content', $modal)

    $content.children().trigger 'modal:close'
    $modal.fadeOut()
