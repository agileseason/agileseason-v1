module BoardIssues
  class StatesController < ApplicationController
    include IssueJsonRenderer
    include Broadcaster
    include WipBadge

    before_action :fetch_board_for_update
    after_action :fetch_control_chart, if: -> { params[:state] =~ /close|reopen/ }

    def update
      issue_stat = send("issue_#{params[:state]}")
      broadcast_column(issue_stat.column, broadcast_force?)
      respond_to do |format|
        format.html { html_result(issue_stat) }
        format.json { render_board_issue_json }
      end
    end

  private

    def issue_close
      IssueStats::Closer.call(
        user: current_user,
        board_bag: @board_bag,
        number: number
      )
    end

    def issue_reopen
      IssueStats::Reopener.call(
        user: current_user,
        board_bag: @board_bag,
        number: number
      )
    end

    def issue_archive
      IssueStats::Archiver.call(
        user: current_user,
        board_bag: @board_bag,
        number: number
      )
    end

    def issue_unarchive
      IssueStats::Unarchiver.call(
        user: current_user,
        board_bag: @board_bag,
        number: number
      )
    end

    def fetch_control_chart
      Graphs::IssueStatsWorker.perform_async(@board.id, encrypted_github_token)
    end

    def html_result(issue_stat)
      if params[:state] =~ /archive/
        render json: wip_badge_json(issue_stat.column)
      else
        head :ok
      end
    end

    def broadcast_force?
      # NOTE: Use force in unarchive because there is no div#issue-n to update.
      !!(params[:state] =~ /unarchive/)
    end
  end
end

