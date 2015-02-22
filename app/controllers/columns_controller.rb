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

  def destroy
    column = @board.columns.find(params[:id])
    if column.issue_stats.blank?
      column.destroy
      render json: { result: true, message: "Column \"#{column.name}\" was successfully deleted.", id: column.id }
    else
      render json: { result: false, message: "Can't delete column with issues!" }
    end
    # NOTE : After 302 redirect board was deleted too! But with 303 page don't reload. :(
    #redirect_to board_url(@board), notice: message, status: 303
  end

  private

  def column_params
    params
      .require(:column)
      .permit(:name)
  end
end
