class SettingsController < ApplicationController
  before_action :fetch_board_for_update

  def show
    render_show(@board)
  end

  def update
    @settings = build_board_settings
    if @settings.save_to(@board)
      redirect_to un(board_settings_url(@board)), notice: 'Settings successfully updated.'
    else
      render_show(@board)
    end
  end

  def rename
    board = Board.find(@board.id)
    if board.update(board_params)
      redirect_to un(board_settings_url(board)), notice: 'Board successfully renamed.'
    else
      render_show(board)
    end
  end

  private

  def render_show(board)
    # NOTE: The local board does not break submenu.
    render :show, locals: { board: board }
  end

  def board_params
    params.
      require(:board).
      permit(:name)
  end

  def scrum_settings_params
    params.
      require(:scrum_settings).
      permit(:days_per_iteration, :start_iteration)
  end

  def kanban_settings_params
    params.
      require(:kanban_settings).
      permit(:rolling_average_window)
  end

  def danger_settings_params
    params.
      require(:danger_settings).
      permit(:is_public)
  end

  def build_board_settings
    if params[:danger_settings]
      DangerSettings.new(danger_settings_params)
    elsif @board.kanban?
      KanbanSettings.new(kanban_settings_params)
    elsif @board.scrum?
      ScrumSettings.new(scrum_settings_params)
    end
  end
end
