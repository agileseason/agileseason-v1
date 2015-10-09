module IssueStats
  class LazySyncChecklist
    include Service
    include Virtus.model

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :number, Integer
    attribute :comments, Object, default: nil

    def call
      issue_stat = IssueStats::Finder.new(user, board_bag, number).call
      IssueStats::SyncChecklist.call(issue_stat: issue_stat, comments: fetch_comments)
      issue_stat
    end

    private

    def fetch_comments
      if comments.nil?
        @comments = user.github_api.issue_comments(board_bag, number)
      end
      comments
    end
  end
end
