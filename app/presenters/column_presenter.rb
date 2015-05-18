class ColumnPresenter < Keynote::Presenter
  presents :column
  delegate :wip_min, :wip_max, to: :column

  def wip_status
    return :alert   if wip_max && column.visible_issue_stats.size > wip_max
    return :warning if wip_min && column.visible_issue_stats.size < wip_min
    :normal
  end
end
