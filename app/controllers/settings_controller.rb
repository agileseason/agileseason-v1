class SettingsController < ApplicationController
  before_action :fetch_board

  def show
  end

  def rename
    if @board.update(board_params)
      redirect_to board_settings_url(@board), notice: 'Rename successful'
    else
      render :show
    end
  end

  private

  def board_params
    params
      .require(:board)
      .permit(:name)
  end
end
