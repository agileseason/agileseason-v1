class RoadmapsController < ApplicationController
  before_action :fetch_board

  helper_method :chart_issues, :chart_dates, :chart_now

  DEFAULT_COLUMN_IDS = [].freeze

  def show
    @column_ids = column_ids
  end

  def build
    redirect_to un board_roadmap_url(@board, column_ids: params[:column_ids])
  end

  private

  def chart_issues
    roadmap.issues.to_json
  end

  def chart_dates
    roadmap.dates.to_json
  end

  def chart_now
    roadmap.current_date.to_json
  end

  private

  def roadmap
    @roadmap ||= Roadmap.call(board_bag: @board_bag, column_ids: column_ids)
  end

  def column_ids
    return DEFAULT_COLUMN_IDS if params[:column_ids].nil?

    ids = params[:column_ids].reject(&:empty?)
    @board.columns.where(id: ids).pluck(:id)
  end
end
