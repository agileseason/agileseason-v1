class Roadmap
  include Service
  include Virtus.model

  attribute :board_bag, BoardBag
  attribute :column_ids, Array, default: []

  ISSUE_WIDTH = 40 # Pixels
  NORM_COEFF = 1.0 / 86400 * ISSUE_WIDTH

  def call
    OpenStruct.new(issues: issues, dates: dates, current_date: current_date)
  end

  private

  def issues
    @min_forecast_closed_at = Time.current
    issues = issue_stats.map do |issue_stat|
      roadmap_issue = RoadmapIssue.call(
        issue_stat: issue_stat,
        free_time_at: @min_forecast_closed_at,
        cycle_time_days: avg_days_per_issue,
        column_ids: column_ids
      )
      next if roadmap_issue.nil?

      @min_forecast_closed_at = roadmap_issue.free_time_at
      github_issue = board_bag.issues_hash[issue_stat.number]
      build_chart_issue(issue_stat, github_issue, roadmap_issue)
    end.compact

    rows_optimizer(issues)
  end

  # TODO Extract RoadmapIssue (and rename service)
  def build_chart_issue(i, github_issue, roadmap_issue)
    {
      number: i.number,
      title: github_issue.present? ? github_issue.title : '<unknown>',
      from: (roadmap_issue.from.to_i - min_from) * NORM_COEFF,
      cycletime: roadmap_issue.cycletime.to_i * NORM_COEFF,
      state: i.state,
      created_at: i.created_at.strftime('%d %b'),
      closed_at: "#{roadmap_issue.to.strftime('%d %b')} #{'(?)' unless i.closed?}",
      column: i.column.name,
      is_archive: i.archived?
    }
  end

  def dates
    issue_stats.
      uniq { |i| i.created_at.to_date }.
      map do |i|
        {
          from: (i.created_at.to_i - min_from) * Roadmap::NORM_COEFF,
          text: i.created_at.strftime('%d %b')
        }
      end.
      uniq { |date| date[:from] } # TODO Fix normalization error if dates are close.
  end

  def current_date
    (Time.current.to_i - min_from) * Roadmap::NORM_COEFF
  end

  def issue_stats
    @issue_stats ||= board_bag.issue_stats.includes(:column).order(:created_at)
  end

  def rows_optimizer(issues)
    rows = []
    max_index = 0
    issues.each do |issue|
      index = rows.index { |r| r < issue[:from] }
      if index.nil?
        index = max_index
        max_index += 1
      end
      rows[index] = issue[:from] + issue[:cycletime]
      issue[:row] = index
    end

    issues
  end

  def avg_days_per_issue
    throughput = frequency_info.throughput
    return 1 if throughput.nil?
    1.0 / throughput
  end

  def frequency_info
    @frequency_info ||= Graphs::FrequencyService.new(board_bag, 1.month.ago)
  end

  def min_from
    @min_from ||= issue_stats.map(&:created_at).min.try(:to_i) || 1
  end
end
