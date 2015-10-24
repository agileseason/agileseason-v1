# Достаточно указать только класс .toggling у контейнера,
# внутри которого именно первым чайлдом лежит скрытый попап.

$(document).on 'ready page:load', ->
  return unless $('.toggling').length
  $('.toggling').toggling()

(($) ->
  $.fn.extend
    toggling: ->
      $('body').on 'click', (e) ->
        return if $(e.target).closest('.toggling-active').length
        $('.toggling').removeClass 'toggling-active'

      @each ->
        $toggling = $(@)
        $toggling.children().first().addClass 'toggling-popup'
        $popup = $('.toggling-popup', $toggling)

        $toggling
          .addClass 'toggling'
          .prepend '<div class="toggling-overlay"></div>'

        $overlay = $('.toggling-overlay', $toggling)

        $toggling.on 'click', (e) ->
          return if $(e.target).closest('.toggling-popup').length

          if $(e.target).closest('.toggling').hasClass 'toggling-active'
            $(e.target).closest('.toggling').removeClass 'toggling-active'
            return

          $('.toggling').removeClass 'toggling-active'
          $(@).addClass 'toggling-active'

        $overlay.on 'click', ->
          console.log 'overlay'
          $toggling.removeClass 'toggling-active'
) jQuery
