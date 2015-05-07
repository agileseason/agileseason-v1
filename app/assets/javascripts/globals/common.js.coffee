$(document).on 'page:change', ->
  $('.l-menu').on 'click', '.boards', ->
    $(@).addClass('active').prepend('<div class="overlay"></div>')
    $(@).find('.popup').show()

  $('.l-menu .boards').on 'click', '.overlay', ->
    $(@).parent().find('.popup').hide()
    $(@).parent().removeClass 'active'
    $(@).remove()

  $('.l-menu .search input').on 'click', ->
    $popup = $(@).parents('.search').find('.popup')
    unless $popup.is(':visible')
      $popup.find('.content').html('')
      $popup.find('.help').show()
      $popup.show()

  $('.l-menu .search input').on 'keyup', (e) ->
    if e.keyCode == 13
      query = $(e.target).val()
      return if query == ''

      $search_container = $(@).parents('.search')
      $popup = $search_container.find('.popup')
      $popup.find('.content').html('<p>Search...</p>')
      $popup.find('.help').hide()

      url = "#{$search_container.data('url')}?query=#{query}"
      $.get url, (search_result) ->
        $popup.find('.content')
          .html(search_result)
        $popup.show()

  $('.l-menu .search .popup .close-popup').on 'click', ->
    $(@).parents('.popup').hide()

  $('.notice').on 'click', ->
    $(@).remove()

  # open activities slider
  $('.l-submenu').on 'click', '.activities-link', ->
    $activities = $('.b-activities')
    $activities
      .trigger 'slider:load'
      .html('<div class="overlay"></div><div class="b-preloader horizontal"></div>')
      .addClass 'active'

    url = $(@).data('url')
    $.get url, { page: 1 }, (activities) ->
      $('.b-preloader', $activities).remove()
      if activities.length > 0
        $activities.append(activities)
      else
        $activities.append('<p class="no-activities">There is no any activity</p>')

  # close activities slider
  $('.b-activities').on 'click', '.overlay', ->
    $(@).parent().removeClass 'active'
    $(@).remove()

  # open issue popup
  $('.b-activities, .search').on 'click', '.issue-url', ->
    # FIX : Need open all issues, not just visible! (Use Issues#show)
    $('.issue-name[data-number="' + $(@).data('number') + '"]').trigger 'click'

$(document).on 'slider:load', '.b-activities', ->
  $('.b-activities').scroll ->
    if $(@).scrollTop() + $(@).innerHeight() >= $(@)[0].scrollHeight && $(@).data('paginate') == true
      $(@).append '<div class="b-preloader horizontal"></div>'
      $(@).data(paginate: false)

      $.get $(@).data('url'), { page: $(@).data('page') }, (data) =>
        if data.length > 0
          $(@).data(page: $(@).data('page') + 1)
          $('.b-preloader', @).remove()
          $(@).append data
          $(@).data(paginate: true)
        else
          $(@).data(paginate: false)
          $('.b-preloader', @).remove()
