class RoadmapsController < ApplicationController
  before_action :fetch_board, only: [:show]

  helper_method :chart_issues, :chart_dates, :chart_now

  def show
  end

  private

  def chart_issues
    Roadmap.call(board_bag: @board_bag).to_json
  end

  # TODO Refactoring this method.
  def chart_dates
    @chart_dates ||= issue_stats.
      uniq { |i| i.created_at.to_date }.
      map do |i|
        {
          from: (i.created_at.to_i - normalization_from) * Roadmap::NORM_COEFF,
          text: i.created_at.strftime('%d %b')
        }
      end.
      uniq { |date| date[:from] }. # TODO Fix normalization error if dates are close.
      to_json
  end

  # TODO Remove copy-past (roadmap.rb)
  def normalization_from
    @normalization_from ||= issue_stats.map(&:created_at).min.try(:to_i) || 1
  end

  def chart_now
    (Time.current.to_i - normalization_from) * Roadmap::NORM_COEFF
  end
end
