$(document).on 'ready page:load', ->
  $('.b-dashboard').on 'wizard:load', ->
    $dashboard = $('.b-dashboard')
    $wizard = $('.b-wizard', $dashboard)
    console.log 'wizard:load'

    $('.boards a.new').click (e) ->
      $(@).addClass 'loading'

      $.ajax
        url: $(@).attr('href'),
        success: (html) =>
          $(@).hide()
          $wizard.show().find('.repos-list').html(html)

          if $('.settings-modal', $dashboard).length
            $('.settings-modal', $dashboard).scrollTo($wizard, 300)
          else
            $(window).scrollTo($wizard, 300)

          $wizard.trigger 'repos:list:load'

      e.preventDefault()

    $wizard.on 'repos:list:load', ->
      console.log 'repos:list:load'

      $('.menu li', $wizard).removeClass('active').addClass 'disabled'
      $('.menu li', $wizard).first().removeClass('disabled').addClass('active')

      $('a.create_board').click (e) ->
        $(@).addClass 'loading'

        $.ajax
          url: $(@).attr('href'),
          success: (html) =>
            $('.repos-list', $wizard).hide()
            $('.new-board-form', $wizard).show().html(html)

            $wizard.trigger 'board:form:load'

        e.preventDefault()

    $wizard.on 'board:form:load', ->
      console.log 'board:form:load'

      $('.menu li', $wizard).first().removeClass('active')
      $('.menu li', $wizard).last().removeClass('disabled').addClass('active')

      $('#board_type_boardskanbanboard').click()
      $('#board_type_boardsscrumboard').prop('disabled', true)
