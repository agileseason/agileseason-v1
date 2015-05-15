class ColumnPresenter < Keynote::Presenter
  presents :column

  def wip_status
    return :alert   if wip_settings.max && column.issue_stats.size > wip_settings.max
    return :warning if wip_settings.min && column.issue_stats.size < wip_settings.min
    :normal
  end

  private

  def wip_settings
    @wip_settings ||= column.wip_settings
  end
end
