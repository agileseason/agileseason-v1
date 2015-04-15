$(document).on 'page:change', ->
  $('.l-menu').on 'click', '.boards', ->
    $(@).addClass('active').prepend('<div class="overlay"></div>')
    $(@).find('.popup').show()

  $('.l-menu .boards').on 'click', '.overlay', ->
    $(@).parent().find('.popup').hide()
    $(@).parent().removeClass 'active'
    $(@).remove()

  $('.notice').on 'click', ->
    $(@).remove()

  # open activities slider
  $('.l-menu').on 'click', '.activities-link', ->
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
  $('.b-activities').on 'click', '.issue-url', ->
    $('.show-issue-modal[data-number="' + $(@).data('number') + '"]').trigger 'click'

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
