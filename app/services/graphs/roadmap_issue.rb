class RoadmapIssue
  include Service
  include Virtus.model

  attribute :issue_stat, IssueStat
  attribute :free_time_at, Time
  attribute :cycle_time_days, Integer
  attribute :column_ids, Array, default: []

  def call
    return if via_lifetime? && lifetimes.blank?

    OpenStruct.new(
      from: from,
      to: to,
      free_time_at: free_time_at,
      cycletime: to - from
    )
  end

  private

  def from
    if via_lifetime?
      lifetimes.min_by(&:in_at).in_at
    else
      issue_stat.created_at
    end
  end

  def to
    @to ||= begin
      return to_fact if to_fact.present?

      self.free_time_at += cycle_time_days.days
      self.free_time_at
    end
  end

  def via_lifetime?
    column_ids.present?
  end

  def lifetimes
    @lifetimes ||= issue_stat.lifetimes.where(column_id: column_ids)
  end

  def to_fact
    @to_fact ||= if via_lifetime?
      unless lifetimes.any? { |lf| lf.out_at.nil? }
        lifetimes.max_by(&:out_at).out_at
      end
    else
      issue_stat.closed_at
    end
  end
end
