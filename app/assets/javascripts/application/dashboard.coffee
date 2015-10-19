class @Dashboard extends View
  initialize: ->
    $dashboard = $('.b-dashboard')
    @$wizard = @$('.b-wizard')
    @$new_board_button = @$('.boards a.new')
    @$list_item = $('.menu li', @$wizard)

    @$new_board_button.on 'click', @_show_repo_list
    @$wizard.on 'repo:list:load', @_repo_list_loaded
    @$wizard.on 'board:form:load', @_board_form_loaded

  _show_repo_list: (e) =>
    @$new_board_button.addClass 'loading'

    $.ajax
      url: @$new_board_button.attr('href'),
      success: (html) =>
        @$new_board_button.hide().removeClass 'loading'
        @$wizard.show().find('.repo-list').html html

        if @$('.settings-modal').length
          @$('.settings-modal').scrollTo @$wizard, 300
        else
          $(window).scrollTo(@$wizard, 300)

        @$wizard.trigger 'repo:list:load'
    e.preventDefault()

  _repo_list_loaded: (e) =>
    @$list_item.removeClass('active').addClass 'disabled'
    @$list_item.first().removeClass('disabled').addClass 'active'

    $('a.create_board').click (e) =>
      $(e.target).addClass 'loading'

      $.ajax
        url: $(e.target).attr('href'),
        success: (html) =>
          $(e.target).removeClass 'loading'
          $('.repo-list', @$wizard).hide()
          $('.new-board-form', @$wizard).show().html html

          @$wizard.trigger 'board:form:load'
      e.preventDefault()

  _board_form_loaded: (e) =>
    @$list_item.first().removeClass 'active'
    @$list_item.last().removeClass('disabled').addClass 'active'

    @$list_item.first().click =>
      $('.new-board-form', @$wizard).hide()
      $('.repo-list', @$wizard).show()
      @$list_item.removeClass('active').addClass 'disabled'
      @$list_item.first().removeClass('disabled').addClass 'active'

    $('#board_type_boardskanbanboard').click()
    $('#board_type_boardsscrumboard').prop 'disabled', true
