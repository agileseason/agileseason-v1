module IssueStats
  class SyncChecklist
    include Service
    include Virtus.model

    attribute :issue_stat, IssueStat
    attribute :comments, Array

    def call
      checklist, checklist_progress = fetch_checklist_and_progress
      issue_stat.update(checklist: checklist, checklist_progress: checklist_progress)
      issue_stat
    end

    private

    def fetch_checklist_and_progress
      text = comments.map(&:body).join('')
      checked = text.scan(/- \[x\] .+/).size
      unchecked = text.scan(/- \[ \] .+/).size
      total = checked + unchecked

      return [nil, nil] if total.zero?
      [total, checked]
    end
  end
end
