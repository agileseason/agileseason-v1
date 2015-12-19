class @IssueTitle extends View
  initialize: ->
    @$title = @$('.issue-title')
    @$textarea = @$('textarea')

    @$textarea.elastic()

    # EditMode:on.
    @$title.on 'click', =>
      val = @$textarea.val()
      @$title.data 'initial-text': @$title.text()
      @$root.addClass 'active'
      @$textarea
        .height @$title.height()
        .focus()
        .val ''
        .val val

    # EditMode:off and save title by blur.
    @$textarea.on 'blur', =>
      @$title.text @$textarea.val()
      @$root.removeClass 'active'
      @$('.button').trigger 'click'

    # EditMode:off and save title (via blur) by enter.
    @$textarea.on 'keydown', (e) =>
      return unless e.keyCode == 13
      @$textarea.blur()
      false
