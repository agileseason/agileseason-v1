class FrequencyService
  def initialize(board)
    @board = board
  end

  def chart_series
    group_durations = fetch_group
    max = group_durations.try(:last).try(:first).to_i
    normolized = (1..max).each_with_object({}) { |day, hash| hash[day] = 0 }
    group_durations.each do |pair|
      normolized[pair.first] = pair.second
    end
    normolized.sort
  end

  def average_elapsed_days(from_at = @board.created_at)
    issues = closed_issues(from_at)
    return if issues.blank?
    (issues.to_a.sum(&:elapsed_days) / issues.count).round(2)
  end

  def closed_issues(from_at = @board.created_at)
    @board.issue_stats.closed.where('closed_at >= ?', from_at)
  end

  def throughput(from_at = @board.created_at)
    issue_stats = @board.issue_stats.closed.where('closed_at >= ?', from_at)
    return if issue_stats.blank?

    passed_days = (Time.current - from_at) / 86400
    issue_stats.count / passed_days
  end

  def throughput_html(from_at = @board.created_at)
    issue_per_day = throughput(from_at)
    if issue_per_day.nil?
      '-'
    else
      "#{issue_per_day.round(2)} issues per day"
    end
  end

  def fetch_group
    @board.issue_stats.closed.each_with_object({ 0 => 0 }) do |issue, hash|
      duration = issue.elapsed_days.to_i + 1
      count = hash[duration] || 0
      hash[duration] = count + 1
    end.sort
  end
end
