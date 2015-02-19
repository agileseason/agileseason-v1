class ColumnsController < ApplicationController
  before_action :fetch_board

  def new
  end

  def create
    @column = Column.new(column_params)
    @column.board = @board
    @column.order = @board.columns.last.order + 1
    if @column.save
      redirect_to board_url(@board)
    else
      render 'new'
    end
  end

  private

  def column_params
    params
      .require(:column)
      .permit(:name)
  end
end
