module Boards
  class Synchronizer
    include Service
    include Virtus.model

    attribute :user, User
    attribute :board, Board

    def call
      not_actual_issue_stats.each do |issue_stat|
        IssueStats::Archiver.new(user, board, issue_stat.number).call
      end
    end

    private

    def issues
      @issues ||= user.github_api.issues(board)
    end

    def not_actual_issue_stats
      numbers_on_board = issues.map(&:number)
      board.issue_stats.visible.where.not(number: numbers_on_board)
    end
  end
end
