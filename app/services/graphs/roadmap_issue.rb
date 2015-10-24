class RoadmapIssue
  include Service
  include Virtus.model

  attribute :issue_stat, IssueStat
  attribute :free_time_at, Time
  attribute :cycle_time_days, Integer
  #TODO Add column params

  def call
    OpenStruct.new(
      from: from,
      to: to,
      free_time_at: free_time_at,
      cycletime: to - from
    )
  end

  private

  def from
    issue_stat.created_at
  end

  def to
    @to ||= begin
      return issue_stat.closed_at if issue_stat.closed_at.present?

      self.free_time_at += cycle_time_days.days
      self.free_time_at
    end
  end
end
