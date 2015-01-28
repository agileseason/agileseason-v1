$(document).on 'ajax:success', (e, html) =>
  $('.l-preloader').hide()

  # открытие попапа
  if $(e.target).data 'modal'
    $('.modal-content').html html
    $('.l-modal').fadeIn 300
    #$('.modal-inner').css('top', $(window).scrollTop() + 100 )
    $('.modal-content').children().trigger 'modal:load'

    # страница борда
    return unless document.body.id == 'boards_show'

    # когда открылся попап тикета
    if $(e.target).hasClass 'issue-name'
      $issue = $(e.target).closest('.issue')
      $issue.addClass 'current-issue'

$(document).on 'page:change', ->
  # закрыть попап по крестику или по клику мимо попапа
  $('.l-modal').on 'click', '.modal-close, .overlay', ->
    $modal = $(@).closest('.l-modal')
    $content = $('> .modal-content', $modal)
    $content.children().trigger 'modal:close'
    $modal.fadeOut()

    # страница борда
    return unless document.body.id == 'boards_show'

    # когда закрывается попапа тикета
    $('.issue').removeClass 'current-issue'
