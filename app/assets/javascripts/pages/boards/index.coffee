$(document).on 'page:change', ->
  return unless document.body.id == 'boards_index'

  $('.boards a.new').click (e) ->
    $(@).addClass 'loading'

    $.ajax
      url: $(@).attr('href'),
      success: (html) =>
        $(@)
          .hide()
          .closest('.b-dashboard')
          .find('.repos')
          .show()
          .find('.repos-list')
          .html(html)

        $(window).scrollTo('.repos', 300)

    e.preventDefault()
