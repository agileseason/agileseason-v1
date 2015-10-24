class @IssueTitle extends View
  initialize: ->
    @$title = @$('.issue-title')
    @$textarea = @$('textarea')

    @$textarea.elastic()

    # редактировать название тикета
    @$title.on 'click', =>
      val = @$textarea.val()
      @$title.data 'initial-text': @$title.text()
      @$root.addClass 'active'
      @$textarea
        .height @$title.height()
        .focus()
        .val ''
        .val val

    # сохранить по блюру название тикета
    @$textarea.on 'blur', =>
      @$title.text @$textarea.val()
      @$root.removeClass 'active'
      @$('.button').trigger 'click'
