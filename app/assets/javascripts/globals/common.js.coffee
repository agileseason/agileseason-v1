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
    $activities.html('<div class="overlay"></div><div class="b-preloader horizontal"></div>')
    $activities.addClass 'active'

    url = $(@).data('url')
    $.get url, {}, (activities) ->
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
