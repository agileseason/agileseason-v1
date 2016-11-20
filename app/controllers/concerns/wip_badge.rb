module WipBadge
  extend ActiveSupport::Concern

  def wip_badge_json(column)
    {
      column_id: column.id,
      html: render_to_string(
        partial: 'columns/wip_badge',
        locals: { column: column }
      )
    }
  end
end
