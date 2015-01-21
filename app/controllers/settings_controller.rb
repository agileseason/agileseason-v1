class SettingsController < ApplicationController
  before_action :fetch_board

  def show
    # NOTE: The local board does not break submenu.
    render :show, locals: { board: @board }
  end

  def rename
    board = Board.find(@board.id)
    if board.update(board_params)
      redirect_to board_settings_url(board), notice: 'Board successfully renamed.'
    else
      render :show, locals: { board: board }
    end
  end

  private

  def board_params
    params
      .require(:board)
      .permit(:name)
  end
end
