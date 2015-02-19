$(document).on 'page:change', ->
  return unless document.body.id == 'boards_show'

  $issue_modal = $('.issue-modal')

  # открыть редактирование
  $issue_modal.on 'click', '.edit-link', ->
    # скрыть открытые формы редактирования
    $('.cancel', '.edit-form:visible').trigger 'click'

    $('.editable', $(@).closest('.edit')).hide()
    $('.edit-form', $(@).closest('.edit'))
      .show()
      .find('.field')
      .focus()

  # закрыть редактирование по кнопке
  $issue_modal.on 'click', '.edit-form .cancel', ->
    close_edit_issue_form($(@).parents('.edit'))

  $issue_modal.on 'click', '.delete-link', ->
    $.get $(@).data('delete')
    $(@).closest('.issue-comment').remove()

  # сабмит редактирования коммента
  $issue_modal.on 'click', '.edit-form button', ->
    $editable = $('.editable', $(@).parents('.edit'))
    return unless $editable.hasClass 'update-comment'

    new_content = $('.field', $(@).parents('.edit-form')).val()

    if new_content.replace(/\s*\n*/g, '') == ''
      $.get $(@).data('delete')
      $(@).closest('.issue-comment').remove()

    else
      $edit_content = $('.editable .edit-content', $(@).parents('.edit'))
      $edit_content.html(new_content)
      $.get $(@).attr('href'), comment: new_content
    close_edit_issue_form($(@).parents('.edit'))

$(document).on 'modal:load', '.b-issue-modal', ->
  return unless document.body.id == 'boards_show'

  $issue_modal = $('.issue-modal')

  # сабмит названия
  $('.issue-title .edit-form button', $issue_modal).click ->
    new_content = $('.field', $(@).parents('.edit-form')).val()
    $editable = $('.editable', $(@).parents('.edit'))
    $edit_content = $(@).parents('.edit').find('.editable .edit-content')
    $current_issue = $('.current-issue') # миниатюра открытого тикета

    $edit_content.html(new_content)
    $('.issue-name', $current_issue).html(new_content)
    $('.issue-title textarea', $current_issue).html(new_content)

    $.get $(@).attr('href'), title: new_content
    close_edit_issue_form($(@).parents('.edit'))

  # сабмит описания
  $('.issue-description .edit-form button', $issue_modal).click ->
    new_content = $('.field', $(@).parents('.edit-form')).val()
    $editable = $('.editable', $(@).parents('.edit'))
    $edit_content = $(@).parents('.edit').find('.editable .edit-content')
    $current_issue = $('.current-issue') # миниатюра открытого тикета
    content = new_content.split("<!--")[0].replace(/\s*\n*/g, '')

    close_edit_issue_form($(@).parents('.edit'))

    if content == ''
      $edit_content.html('Description').addClass 'label'
      $('.octicon-book', $current_issue).hide()
      $('.issue-description .edit-content', $current_issue)
        .html('Description')
        .addClass 'label'
    else
      $edit_content.html(new_content)
      $('.octicon-book', $current_issue).show()
      $edit_content.html(new_content).removeClass 'label'
      $('.issue-description .edit-content', $current_issue)
        .html(new_content)
        .removeClass ('label')

    $('.issue-description textarea', $current_issue).html(new_content)
    $.get $(@).attr('href'), body: new_content

  # сабмит добавления коммента
  $('.add-comment .edit-form button', $issue_modal).click ->
    new_content = $('.field', $(@).closest('.edit-form')).val()

    unless new_content.replace(/\s*\n*/g, '') == ''
      $current_issue = $('.current-issue') # миниатюра открытого тикета

      $issue_modal = $('.issue-modal')
      $('.issue-comments', $issue_modal)
        .prepend('<div class="b-preloader horizontal"></div><br><br>')

      $.get $(@).attr('href'), comment: new_content, ->
        # перезагрузить весь список комментариев
        comments_url = $('.issue-comments', $issue_modal).data('url')
        $.get comments_url, (comments) ->
          $('.issue-comments', $issue_modal).html(comments)
          $('.b-preloader', $issue_modal).hide()

        # отобразить иконку с комментарием в миниатюре
        $('.octicon-comment-discussion', $current_issue).show()

    close_edit_issue_form($(@).parents('.edit'))

close_edit_issue_form = ($parent_node) ->
  $('.editable', $parent_node).show()
  $('.edit-form', $parent_node).hide()
