class @Activities extends View
  initialize: ->
    @$activities = @$('.b-activities')

    @$('.activities-link').on 'click', @_show_activities
    @on 'click', '.overlay', @_hide_activities
    @$activities.on 'slider:load', =>
      @$activities.scroll (e) => @_scroll_activities(e)

  _scroll_activities: (e) =>
    if scroll_conditions(e)
      @$activities.append '<div class="b-preloader"></div>'
      @$activities.data paginate: false

      $.ajax
        url: @$activities.data('url'),
        data: page: @$activities.data('page')
        success: (data) => @_paginate(data)

  _paginate: (data) =>
    if data.length > 0
      @$activities.data page: @$activities.data('page') + 1
      @$('.b-preloader').remove()
      @$activities.append data
      @$activities.data paginate: true

    else
      @$activities.data paginate: false
      @$('.b-preloader').remove()


  scroll_conditions = (e) ->
    $(e.target).scrollTop() + $(e.target).innerHeight() >= $(e.target)[0].scrollHeight &&
      $(e.target).data('paginate') == true

  _show_activities: (e) =>
    @$activities
      .trigger 'slider:load'
      .html('<div class="overlay"></div><div class="b-preloader"></div>')
      .addClass 'active'
    @_insert_activities()

  _insert_activities: =>
    url = @$root.data('url')
    $.get url, { page: 1 }, (activities) =>
      @$('.b-preloader').remove()
      if activities.length > 0
        @$activities.append(activities)
      else
        @$activities.append('<p class="no-activities">There is no any activity</p>')

  _hide_activities: (e) =>
    @$activities.removeClass 'active'
    @$('.overlay').remove()
