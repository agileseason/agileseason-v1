module IssueStats
  class SyncChecklist
    include Service
    include Virtus.model

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :number, Integer
    attribute :comments, Object, default: nil

    def call
      issue_stat = IssueStats::Finder.new(user, board_bag, number).call
      checklist, checklist_progress = fetch_checklist_and_progress
      issue_stat.update(checklist: checklist, checklist_progress: checklist_progress)
      issue_stat
    end

    private

    def fetch_comments
      if comments.nil?
        @fetch_comments ||= user.github_api.issue_comments(board_bag, number)
      else
        comments
      end
    end

    def fetch_checklist_and_progress
      text = fetch_comments.map(&:body).join('')
      checked = text.scan(/- \[x\] .+/).size
      unchecked = text.scan(/- \[ \] .+/).size
      total = checked + unchecked

      return [nil, nil] if total.zero?
      [total, checked]
    end
  end
end
