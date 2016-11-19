module BoardIssues
  class MovesController < ApplicationController
    include CumulativeGraphUpdater
    include IssueJsonRenderer
    include LinesGraphUpdater
    include WipBadge

    before_action :fetch_board_for_update

    def update
      issue_stat = IssueStats::Finder.new(current_user, @board_bag, number).call

      column_to = @board.columns.find(params[:column_id])
      column_from = issue_stat.column

      IssueStats::Mover.call(
        user: current_user,
        board_bag: @board_bag,
        column_to: column_to,
        number: number,
        is_force_sort: !!params[:force]
      )

      broadcast_column(column_from, params[:force])
      broadcast_column(column_to, params[:force])

      issue_stat.reload
      # NOTE Includes(:issue_stats) to remove N+1 query in view 'columns/wip_badge'.
      columns = Column.includes(:issue_stats).where(board_id: @board.id)
      render json: { badges: columns.map { |column| wip_badge_json(column) } }
    end
  end
end
