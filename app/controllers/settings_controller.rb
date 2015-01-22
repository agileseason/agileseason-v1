class SettingsController < ApplicationController
  before_action :fetch_board

  def show
    # NOTE: The local board does not break submenu.
    render_show(@board)
  end

  def update
    @settings = ScrumSettings.new(scrum_settings_params)
    if @settings.save_to(@board)
      redirect_to board_settings_url(@board), notice: 'Settings successfully updated.'
    else
      render_show(@board)
    end
  end

  def rename
    board = Board.find(@board.id)
    if board.update(board_params)
      redirect_to board_settings_url(board), notice: 'Board successfully renamed.'
    else
      render_show(board)
    end
  end

  private

  def render_show(board)
    render :show, locals: { board: board }
  end

  def board_params
    params
      .require(:board)
      .permit(:name)
  end

  def scrum_settings_params
    params
      .require(:scrum_settings)
      .permit(:days_per_iteration, :start_iteration)
  end
end
