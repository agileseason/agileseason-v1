class RoadmapsController < ApplicationController
  before_action :fetch_board, only: [:show]

  helper_method :chart_issues, :chart_dates, :chart_now

  ISSUE_WIDTH = 40
  NORM_COEFF = 1.0 / 86400 * ISSUE_WIDTH

  def show
  end

  private

  def chart_issues
    issues.to_json
  end

  # TODO Refactoring this method.
  def chart_dates
    @chart_dates ||= issue_stats.
      uniq { |i| i.created_at.to_date }.
      map do |i|
        {
          from: (i.created_at.to_i - normalization_from) * NORM_COEFF,
          text: i.created_at.strftime('%d %b')
        }
      end.
      uniq { |date| date[:from] }. # TODO Fix normalization error if dates are close.
      to_json
  end

  # TODO Refactoring this method.
  def issues
    @min_forecast_closed_at = Time.current
    issues = issue_stats.
      map do |i|
        github_issue = @board_bag.issues_hash[i.number]
        closed_at = calculate_closed_at(i)
        {
          number: i.number,
          title: github_issue.present? ? github_issue.title : '<unknown>',
          from: (i.created_at.to_i - normalization_from) * NORM_COEFF,
          cycletime: (closed_at.to_i - i.created_at.to_i) * NORM_COEFF,
          state: i.state,
          created_at: i.created_at.strftime('%d %b'),
          closed_at: "#{closed_at.strftime('%d %b')} #{'(?)' unless i.closed?}",
          column: i.column.name,
          is_archive: i.archived?
        }
      end
    rows_optimizer(issues)
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

  def calculate_closed_at(issue)
    return issue.closed_at if issue.closed_at.present?

    closed_at = @min_forecast_closed_at
    @min_forecast_closed_at += avg_cycle_time
    closed_at
  end

  def avg_cycle_time
    @avg_cycle_time ||= avg_days_per_issue.days
  end

  def avg_days_per_issue
    throughput = frequency_info.throughput
    return 1 if throughput.nil?
    1.0 / throughput
  end

  def frequency_info
    @frequency_info ||= Graphs::FrequencyService.new(@board, 1.month.ago)
  end

  def normalization_from
    @normalization_from ||= issue_stats.map(&:created_at).min.try(:to_i) || 1
  end

  def issue_stats
    @issue_stats ||= @board.issue_stats.includes(:column).order(:created_at)
  end

  def chart_now
    (Time.current.to_i - normalization_from) * NORM_COEFF
  end
end
