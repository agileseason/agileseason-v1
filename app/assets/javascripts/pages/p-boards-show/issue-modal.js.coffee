$(document).on 'modal:load', '.b-issue-modal', ->
  return unless document.body.id == 'boards_show'

  $issue_modal = $('.issue-modal')

  # открыть редактирование
  $issue_modal.on 'click', '.edit-link', ->
    # скрыть открытые формы редактирования
    $('.edit-form .cancel').trigger 'click'

    $('.editable', $(@).closest('.edit')).hide()
    $('.edit-form', $(@).closest('.edit')).show()
      .find('.field').focus()

  # закрыть редактирование по кнопке
  $issue_modal.on 'click', '.edit-form .cancel', ->
    close_edit_issue_form($(@).parents('.edit'))

  # сабмит
  $issue_modal.on 'click', '.edit-form button',->
    new_content = $('.field', $(@).parents('.edit-form')).val()
    close_edit_issue_form($(@).parents('.edit'))
    $editable = $('.editable', $(@).parents('.edit'))
    $edit_content =  $(@).parents('.edit').find('.editable .edit-content')

    if $editable.hasClass 'description'
      $edit_content.html(new_content)
      $.get $(@).attr('href'), { body: new_content }

    else if $editable.hasClass 'title'
      $edit_content.html(new_content)
      $('.issue-name', $('.current-issue')).html(new_content)
      $.get $(@).attr('href'), { title: new_content }

    else if $editable.hasClass 'update-comment'
      $edit_content.html(new_content)
      $.get $(@).attr('href'), { comment: new_content }

    else if $editable.hasClass 'create-comment'
      $.get $(@).attr('href'), { comment: new_content }
      $issue_modal = $('.issue-modal')
      $('.issue-comments', $issue_modal).html('<div class="b-preloader horizontal"></div>')

      comments_url = $('.issue-comments', $issue_modal).data('url')
      $.get comments_url, (comments) =>
        $('.issue-comments', $issue_modal).html(comments)
        $('.b-preloader', $issue_modal).hide()

close_edit_issue_form = ($parent_node) ->
  $('.editable', $parent_node).show()
  $('.edit-form', $parent_node).hide()
