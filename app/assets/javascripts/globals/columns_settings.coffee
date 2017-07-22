#@$root is $('ul.columns li') or $('.column-menu')
class @ColumnsSettings extends View
  initialize: ->
    @$('.js-patch').js_patch()

    @$('.autoassign input').on 'change', @_toggle_autoassign
    @$('.delete').on 'ajax:success', @_fade_out_column
    @$('input[name="name"]').on 'blur', @_update_name
    @$('input[name="wip_min"], input[name="wip_max"]').on 'blur', @_update_wip

  _update_name: (e) =>
    return if @$root.is 'ul.columns li'
    @$('.title>a').text $(e.target).val()

  _update_wip: (e) =>
    return if @$root.is 'ul.columns li'
    $issues = @$root.next()
    issues_number = $('.issue', $issues).length

    min = @$('input[name="wip_min"]').val()
    max = @$('input[name="wip_max"]').val()

    if (min != '' && issues_number < parseInt(min)) ||
        (max != '' && issues_number > parseInt(max))
      @$('.badge').show().text(issues_number).addClass 'alert'

    else
      @$('.badge').hide()

  _toggle_autoassign: =>
    @$('.autoassign').toggleClass 'active'
    @board_column = @$root.parent('.board-column')
    is_auto_assign = !@board_column.data('auto-assign')
    @board_column
      .attr('data-auto-assign', is_auto_assign)
      .data('auto-assign', is_auto_assign)

  _fade_out_column: =>
    @$root.fadeOut()
    Turbolinks.visit(document.location.href) unless document.body.id == 'settings_show'
