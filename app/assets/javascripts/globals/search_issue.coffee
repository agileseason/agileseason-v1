class @SearchIssue extends View
  initialize: ->
    @$popup = @$('.search-popup')
    @$input = @$('input')
    @$content = @$('.search-content')
    @$help = @$('.help')

    @$('input, .octicon-search').on 'click', @_show_search
    @$input.on 'keyup', @_submit_search
    @$('.overlay').on 'click', => @$root.removeClass 'active'

  _submit_search: (e) =>
    if e.keyCode == 13
      query = $(e.target).val()
      return if query == ''
      @$content.html '<p>Search...</p>'
      @$help.hide()

      url = "#{@$root.data 'url'}?query=#{query}"
      $.get url, (search_result) =>
        @$content.html search_result
        @$popup.show()

  _show_search: =>
    @$root.addClass 'active'
    @$input.focus()

    unless @$popup.is ':visible'
      @$content.html ''
      @$help.show()
      @$popup.show()
