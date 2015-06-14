$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  ################################################################################
  # issue modal loaded
  ################################################################################
  $('.issue-modal').on 'modal:load', ->
    return unless document.body.id == 'boards_show'
    #console.log 'modal:load'

    $('pre code').each (i, block) ->
      hljs.highlightBlock block

    init_uploading()

    $current_issue = $('.issue[data-number="' + $(@).closest('.b-issue-modal').data('number') + '"]') # миниатюра открытого тикета
    $issue_modal = $('.issue-modal')

    load_comments()

    $('.b-issue-modal').click (e) ->
      unless $(e.target).is('.editable-form.active textarea, .editable-form.active .save, .preview, .attach-images, controls, .upload, .upload input, .write')
        close_active_form()

    $('textarea', '.add-comment-form').click (e) ->
      $form = $(@).closest('.add-comment-form')
      $form.addClass 'active'
      $('textarea', $form)
        .val($(e.target).parents('.editable').data('initial'))
        .focus()
        .elastic()

      e.stopPropagation()

    $('.editable').click (e) ->
      if $(e.target).is(':checkbox')
        return

      unless $(@).closest('.add-comment-form').length > 0
        open_form($(@))

    $('.write').click ->
      $(@).closest('form').removeClass('preview-mode')

    $('.editable-form').click (e) ->
      if $(e.target).is('.add-comment-form.active .save')
        $form = $(@).closest '.editable-form'
        url = $form.data('url')
        new_content = $('textarea', '.editable-form.active').val()

        $('textarea', '.editable-form.active').val('')

        $current_issue = $('.current-issue')

        unless new_content == ''
          $('.issue-comments').append('<div class="b-preloader horizontal"></div>')
          $.post url, body: new_content, ->
            $('.octicon-comment-discussion', $current_issue).addClass 'show'
            load_comments()

        close_active_form()

      else if $(e.target).is('.editable-form.active .save')
        $(@).trigger('form:save')

    $('.editable-form').on 'form:save', ->
      #console.log 'form:save'

      $form = $(@)
      $editable_node = $(@).prev()
      $current_issue = $('.current-issue') # миниатюра открытого тикета

      url = $form.prev().data('url')
      new_content = $('textarea', '.editable-form.active').val()

      # issue name save
      if $(@).prev().hasClass 'issue-name'
        $editable_node.html(new_content)
        #console.log 'title:submit'
        $('.issue-name', $current_issue).html(new_content)

        $.post url, title: new_content
        close_active_form()

      # description save
      else if $(@).prev().hasClass 'description'
        if new_content == ''
          $editable_node.html('Description').addClass 'blank-description'
          $('.octicon-book', $current_issue).hide()

        else
          update_initial_data($(@), new_content)
          $.post $('.preview', @).data('url'), string: new_content, (markdown) ->
            $editable_node.html(markdown).removeClass 'blank-description'
          $('.octicon-book', $current_issue).show()

        $.post url, body: new_content
        close_active_form()

      # save a new comment
      else if $(@).prev().hasClass 'add-comment'
        unless new_content == ''
          $('.issue-comments').append('<div class="b-preloader horizontal"></div>')
          $.post url, body: new_content, ->
            $('.octicon-comment-discussion', $current_issue).addClass 'show'
            load_comments()

        close_active_form()

    $('.issue-description').on 'click', '.task', (e) ->
      update_by_checkbox($(@), '.description')

    ################################################################################
    # comments are loaded in issue modal
    ################################################################################
    $('.issue-comments').on 'comments:load', ->
      #console.log 'comments:load'

      $('pre code').each (i, block) ->
        hljs.highlightBlock block

      init_uploading()

      $('.delete', @).click ->
        if window.confirm('Delete comment?')
          $.ajax
            method: 'DELETE'
            url: $(@).data('url')
            success: ->
            if $('.comment', $issue_modal).length < 1
              $('.octicon-comment-discussion', $current_issue).removeClass 'show'

          $(@).closest('.issue-comment').remove()

      $('.preview', $issue_modal).click ->
        string = $('textarea', $(@).closest('form')).val()

        $.post $(@).data('url'), string: string, (markdown) =>
          $(@).closest('form').addClass('preview-mode')
          $('.preview-textarea', $(@).closest('form')).html(markdown)

      $('.write').click ->
        $(@).closest('form').removeClass('preview-mode')

      $('.edit', @).click ->
        open_form($(@).closest('.controls').next())
        $('.editable-form', $(@).closest('.comment-body')).trigger 'comment_form:load'

      $('.editable-form').on 'comment_form:load', ->
        #console.log 'comment_form:load'

        $('.editable-form', '.issue-comments').click (e) ->
          if $(e.target).is('.editable-form.active .save')
            $(@).trigger('comment:save')

      $('.editable-form', '.issue-comments').on 'comment:save', ->
        $form = $(@)
        $editable_node = $(@).prev()
        $current_issue = $('.current-issue') # миниатюра открытого тикета

        url = $form.prev().data('url')
        new_content = $('textarea', '.editable-form.active').val()

        if new_content.replace(/\s*\n*/g, '') == ''
          close_active_form()

        else
          update_initial_data($(@), new_content)
          $.post url, body: new_content
          $.post $('.preview', @).data('url'), string: new_content, (markdown) ->
            $editable_node.html(markdown)
            close_active_form()

      $('.issue-comments').on 'click', '.task', (e) ->
        update_by_checkbox($(@), '.comment')

    ################################################################################
    # move-to events in issue modal
    ################################################################################
    $('.move-to-column li', $issue_modal).each ->
      $(@).addClass('active') if $(@).data('column') == $current_issue.closest('.board-column').data('column')

    # Перемещение тикета в попапе
    $('.move-to-column li', $issue_modal).click ->
      return if $(@).hasClass 'active'

      # класс активной колонки
      $('.move-to-column li').removeClass 'active'
      $(@).addClass 'active'

      $current_issue = $(".issue.issue-#{$(@).parents('.b-issue-modal').data('number')}")
      column_1 = $current_issue.data('column')
      column_2 = $(@).data('column')
      $col_1 = $("#column_#{column_1}")
      $col_2 = $("#column_#{column_2}")

      # перемещение тикета в DOMe
      clone = $current_issue
      $current_issue.remove()
      $('.issues', $col_2).prepend(clone)

      $.get $(@).data('move-to-url')

      # сохранение порядка тиетов в измененных колонках
      col_1_issues = empty_check($col_1.find('.issues').sortable('serialize'), '')
      col_2_issues = empty_check($col_2.find('.issues').sortable('serialize'), $current_issue.data('number'))
      save_order($col_1.data('url'), col_1_issues)
      save_order($col_2.data('url'), col_2_issues)

load_comments = ->
  #console.log 'load comments'
  $issue_comments = $('.issue-comments')
  comments_url = $issue_comments.data('url')

  $.get comments_url, {}, (comments) ->
    $issue_comments.html(comments)
    setTimeout ->
        $issue_comments.trigger 'comments:load'
      , 300

open_form = ($editable_node) ->
  #console.log 'open form'
  setTimeout ->
      if $editable_node.data('initial')
        initial_data = $editable_node.data('initial').toString().trim()
      else
        initial_data = $editable_node.html().trim()

      $editable_node
        .hide()
        .next().show().addClass('active')
        .find('textarea')
          .focus()
          .val(initial_data)
          #.elastic()
    , 300

close_active_form = ->
  #console.log 'close active form'
  if $('.editable-form.active').length > 0
    $textarea = $('.editable-form.active').find('textarea')
    if $('.editable-form.active').is('.editable')
      $('.editable-form.active').data('initial', $textarea.val())
    else
      # FIX : For description initial in .editable. For comment initial in .comment!
      $('.editable-form.active').parent().find('.editable, .comment').data('initial', $textarea.val())

    $textarea.val('')
    $textarea.height(20) # Back height after elastic.
    $('.editable-form.active')
      .hide()
      .removeClass('active')
      .prev().show()

empty_check = (issues, moving_issue) ->
  if issues
    issues
  else
    if moving_issue
      { issues: [moving_issue] }
    else
      { issues: ['empty'] }

save_order = (url, data) ->
  $.ajax
    url: url,
    method: 'PATCH',
    data: data

init_uploading = ->
  url = $('.board').data('direct_post_url')
  form_data = $('.board').data('direct_post_form_data')
  window.init_direct_upload($('.directUpload').find('input:file'), url, form_data)

update_by_checkbox = ($checkbox, container_selector) ->
  event.stopPropagation()
  $container = $checkbox.parents(container_selector)
  checkbox_index = $checkbox.index("#{container_selector} .task")
  checkbox_value = $checkbox.is(':checked')
  initial_body = $container.data('initial')
  new_body = replaceNthMatch(initial_body, /(\[(?:x|\s)\])/, checkbox_index + 1, if checkbox_value then '[x]' else '[ ]')

  $.post($container.data('url'), body: new_body)
  update_initial_data($container, new_body)

update_initial_data = ($element, new_content) ->
  if $element.attr('data-initial')
    $element.data('initial', new_content)
  else
    $element.parent().find('[data-initial]').data('initial', new_content)
