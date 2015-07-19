class FrequencyService
  ZERO_POINT = { 0 => 0 }

  pattr_initialize :board, :from_at

  def issues
    @issues ||= board.
      reload.
      issue_stats.
      closed.
      where('closed_at >= ?', from_at).
      to_a
  end

  def chart_series
    return ZERO_POINT if issues.blank?

    max = issues.map(&:elapsed_days).max
    normolized = (1..max.ceil).each_with_object(ZERO_POINT) do |day, hash|
      hash[day] = 0
    end

    issues.each do |issue|
      duration = issue.elapsed_days.ceil
      normolized[duration] += 1
    end

    normolized
  end

  def avg_lifetime
    return if issues.blank?

    (issues.sum(&:elapsed_days) / issues.count).round(2)
  end

  def avg_lifetime_percentile(persentile)
    return if issues.blank?

    bound = percentile_elapsed_days_bound(persentile, issues.map(&:elapsed_days))
    percentile_issues = issues.select { |issue| issue.elapsed_days <= bound }
    (percentile_issues.sum(&:elapsed_days) / percentile_issues.count).round(2)
  end

  def throughput
    return if issues.blank?

    passed_days = (Time.current - from_at) / 86400
    issues.count / passed_days
  end

  private

  def percentile_elapsed_days_bound(percentile, elapsed_days)
    min, max = elapsed_days.minmax
    (max - min) * percentile + min
  end
end
