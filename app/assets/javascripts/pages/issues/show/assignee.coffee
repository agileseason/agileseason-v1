window.assignee = ->
  # раскрыть попап с пользователями для назначения
  $('.assignee').click ->
    $('.issue-popup').hide()
    $(@).parent().find('.issue-popup').show()

    $('.overlay', '.issue-actions').show()

  $('.b-assign .user').click (e) ->

    if $('.check', @).hasClass 'octicon octicon-check'
      $('.check', @).removeClass 'octicon octicon-check'
      $('.b-assignee', '.user-list').addClass 'hidden'

    else
      img_src = $(@).find('img').attr('src')
      $('img', '.user-list').attr('src', img_src)

      a_href = $(@).find('a').attr('href')
      a_title = $(@).find('.name').text()
      $('a', '.user-list')
        .attr('href', a_href)
        .attr('title', a_title)

      $('.b-assign .user .check').removeClass 'octicon octicon-check'

      $('.check', @).addClass 'octicon octicon-check'
      $('.b-assignee', '.user-list').removeClass 'hidden'

