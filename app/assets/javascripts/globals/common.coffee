$ ->
  Turbolinks.enableProgressBar true

$(document).on 'left:menu:show', ->
  $('.overlay', '.left-menu').click ->
    $('.left-menu').removeClass 'show'

$(document).on 'page:change', ->
  $('.notice').on 'click', ->
    $(@).remove()

  # открыть модальное окно с issue по прямой сслыке
  if location.hash
    number = location.hash.match(/issue-number=(\d+)/)?[1]
    show_issue_modal(number) if number

  $('.issues').on 'click', '.issue.draggable', (e) ->
    unless $(e.target).is('a, .button')
      $(@).closest('.issue').addClass 'current-issue'
      show_issue_modal($(@).data('number'))

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
          $issue_modal.trigger 'dashboard:load'

  $('.settings-modal').on 'dashboard:load', ->

    $('.boards a.new').click (e) ->
      $(@).addClass 'loading'

      $.ajax
        url: $(@).attr('href'),
        success: (html) =>
          $(@)
            .hide()
            .closest('.modal-content')
            .find('.repos')
            .show()
            .find('.repos-list')
            .html(html)

          $('.settings-modal').scrollTo('.repos', 300)

      e.preventDefault()

  # скрыть дашборд
  $('.l-menu .boards').click (e) ->
    return if $(e.target).is('.current-board-link')

    if $(e.target).is('.overlay', '.l-menu .boards')
      $(@).find('.popup').hide()
      $(@).removeClass 'active'
      $(@).find('.overlay').remove()

    else
      $(@).addClass('active').prepend('<div class="overlay"></div>')
      $(@).find('.popup').show()

  $('.l-menu .search').on 'click', 'input, .octicon-search', ->
    $('input', $(@).closest('.search')).focus().addClass 'active'
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

    # open activities slider
  $('.l-menu').on 'click', '.activities-link', ->
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

  # open issue popup
  $('.b-activities, .search').on 'click', '.issue-url', ->
    # FIX : Need open all issues, not just visible! (Use Issues#show)
    #$('.issue-name[data-number="' + $(@).data('number') + '"]').trigger 'click'
    show_issue_modal($(@).data('number'))

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

show_issue_modal = (number) ->
  $issue_modal = $('.issue-modal')
  $modal_content = $('.modal-content', $issue_modal)
  $issue_modal.show()
  $modal_content.html('<div class="b-issue-modal" style="text-align: center;"><div class="b-preloader modal-preloader"></div></div>')

  $.ajax
    url: "/boards/#{$('.board').data('github_full_name')}/issues/#{number}",
    success: (html) ->
      $modal_content.html($(html)).trigger 'modal:load'
      location.hash = "#issue-number=#{number}"
