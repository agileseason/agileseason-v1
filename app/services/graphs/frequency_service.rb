class FrequencyService
  pattr_initialize :board

  ZERO_POINT = { 0 => 0 }

  def chart_series(from_at = board.created_at)
    issues = closed_issues(from_at)
    max = issues.map(&:elapsed_days).max
    return ZERO_POINT if max.nil?

    normolized = (1..max.ceil).each_with_object(ZERO_POINT) do |day, hash|
      hash[day] = 0
    end

    issues.each do |issue|
      duration = issue.elapsed_days.ceil
      normolized[duration] = normolized[duration] + 1
    end

    normolized
  end

  def avg_lifetime(from_at = board.created_at)
    issues = closed_issues(from_at)
    return if issues.blank?

    (issues.to_a.sum(&:elapsed_days) / issues.count).round(2)
  end

  def avg_lifetime_percentile(persentile, from_at = board.created_at)
    issues = closed_issues(from_at)
    return if issues.blank?

    bound = percentile_elapsed_days_bound(persentile, issues.map(&:elapsed_days))
    percentile_issues = issues.select { |issue| issue.elapsed_days <= bound }
    (percentile_issues.sum(&:elapsed_days) / percentile_issues.count).round(2)
  end

  def closed_issues(from_at = board.created_at)
    board.issue_stats.closed.where('closed_at >= ?', from_at)
  end

  def throughput(from_at = board.created_at)
    issue_stats = board.issue_stats.closed.where('closed_at >= ?', from_at)
    return if issue_stats.blank?

    passed_days = (Time.current - from_at) / 86400
    issue_stats.count / passed_days
  end

  def throughput_html(from_at = board.created_at)
    issue_per_day = throughput(from_at)
    if issue_per_day.nil?
      '-'
    else
      "#{issue_per_day.round(2)} issues per day"
    end
  end

  private

  def fetch_group(issues)
    issues.each_with_object({ 0 => 0 }) do |issue, hash|
      duration = issue.elapsed_days.to_i + 1
      count = hash[duration] || 0
      hash[duration] = count + 1
    end.sort
  end

  def percentile_elapsed_days_bound(percentile, elapsed_days)
    min, max = elapsed_days.minmax
    (max - min) * percentile + min
  end
end
