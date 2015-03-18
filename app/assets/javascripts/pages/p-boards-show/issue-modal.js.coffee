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
    if window.confirm('Delete comment?')
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
  $current_issue = $('.issue[data-number="' + $(@).closest('.b-issue-modal').data('number') + '"]') # миниатюра открытого тикета
  $issue_modal = $('.issue-modal')

  $('.move-to-column li', $issue_modal).each ->
    $(@).addClass('active') if $(@).data('column') == $current_issue.closest('.board-column').data('column')

  # Перемещение тикета в попапе
  $('.move-to-column li', $issue_modal).click ->
    return if $(@).hasClass 'active'

    # класс активной колонки
    $('.move-to-column li').removeClass 'active'
    $(@).addClass 'active'

    # перемещение тикета в DOMe
    $column = $('.board-column[data-column="' + $(@).data('column') + '"]')
    clone = $current_issue
    $current_issue.remove()
    $('.issues', $column).prepend(clone)

    # урл перемещения
    board_github_name = $('.board').data('github_name')
    issue = $current_issue.data('number')
    column = $(@).data('column')
    path = "/boards/#{board_github_name}/issues/#{issue}/move_to/#{column}"
    $.get path

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
    $comment_textarea = $('.field', $(@).closest('.edit-form'))
    new_content = $comment_textarea.val()

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
          $comment_textarea.val('')

        # отобразить иконку с комментарием в миниатюре
        $('.octicon-comment-discussion', $current_issue).show()

    close_edit_issue_form($(@).parents('.edit'))

close_edit_issue_form = ($parent_node) ->
  $('.editable', $parent_node).show()
  $('.edit-form', $parent_node).hide()
