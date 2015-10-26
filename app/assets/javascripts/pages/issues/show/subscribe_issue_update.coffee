window.subscribe_issue_update = ->
  $issue = $('.b-issue-modal')
  return unless $issue.data('faye-on')
  return unless window.faye

  try
    window.faye.apply $issue.data('faye-channel'), $issue

    $issue.on 'faye:comment_create', (e, data) ->
      window.faye.updateProcessTime()
      $fetch_issue = $('.b-issue-modal')
      return unless $fetch_issue.data('number') == parseInt(data.number)
      $('.issue-comments').append(data.html)

  catch err
    console.log err
