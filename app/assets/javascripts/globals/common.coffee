$ ->
  Turbolinks.enableProgressBar true

$(document).on 'page:change', ->
  $('.notice').on 'click', ->
    $(@).remove()

  $('.issues').on 'click', '.issue.draggable', (e) ->
    unless $(e.target).is('a, .button')
      $(@).closest('.issue').addClass 'current-issue'
      Turbolinks.visit $(@).data('url')

  # закрыть попап по крестику или по клику мимо попапа
  $('.modal').on 'click', '.modal-close, .overlay, .close-settings', ->
    $modal = $(@).closest('.modal')
    $content = $('> .modal-content', $modal)
    $content.children().trigger 'modal:close'
    $modal.hide()

    if $modal.hasClass 'issue-modal'
      $('.b-issue-modal', $modal).remove()
      # снять отметку текущего тикета
      $('.current-issue').removeClass('current-issue')
      # убрать #issue-number от прямой ссылки на issue
      location.hash = ''

    # страница борда
    return unless document.body.id == 'boards_show'

  # открыть дашборд
  $('.left-menu-link').click ->
    $issue_modal = $('.settings-modal')
    $board_list = $('.board-lists', $issue_modal)
    $issue_modal.show()

    unless $('.board-list ul', $issue_modal).length
      $('.b-preloader', $board_list).show()

      $.ajax
        url: $(@).data('url'),
        success: (html) ->
          $('.b-preloader', $board_list).hide()
          $board_list.html($(html))
          $('.b-dashboard').trigger 'wizard:load'

  # скрыть дашборд
  $('.b-menu .boards').click (e) ->
    return if $(e.target).is('.current-board-link')

    if $(e.target).is('.overlay', '.b-menu .boards')
      $(@).find('.popup').hide()
      $(@).removeClass 'active'
      $(@).find('.overlay').remove()

    else
      $(@).addClass('active').prepend('<div class="overlay"></div>')
      $(@).find('.popup').show()

  $('.b-menu .search').on 'click', 'input, .octicon-search', ->
    $('input', $(@).closest('.search')).focus().addClass 'active'
    $popup = $(@).parents('.search').find('.popup')
    unless $popup.is(':visible')
      $popup.find('.content').html('')
      $popup.find('.help').show()
      $popup.show()

  $('.b-menu .search input').on 'keyup', (e) ->
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

  $('.b-menu .search .popup .close-popup').on 'click', ->
    $(@).parents('.popup').hide()

    # open activities slider
  $('.b-menu').on 'click', '.activities-link', ->
    $activities = $('.b-activities')
    $activities
      .trigger 'slider:load'
      .html('<div class="overlay"></div><div class="b-preloader"></div>')
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

$(document).on 'slider:load', '.b-activities', ->
  $('.b-activities').scroll ->
    if $(@).scrollTop() + $(@).innerHeight() >= $(@)[0].scrollHeight && $(@).data('paginate') == true
      $(@).append '<div class="b-preloader"></div>'
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
