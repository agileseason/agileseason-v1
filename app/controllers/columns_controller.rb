class ColumnsController < ApplicationController
  include PatchAttributes
  before_action :fetch_board_for_update

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

  def edit
  end

  def update
    @column = @board.columns.find(params[:id])

    if params[:issues]
      issue_ids = params[:issues].reject{ |n| n == 'empty' }.uniq
       @column.update(issues: issue_ids)
       render nothing: true
    else
      if @column.update(column_params)
        redirect_to board_url(@board)
      else
        render 'edit'
      end
    end
  end

  def destroy
    column = @board.columns.find(params[:id])
    # FIX : Replace json on redirect_to or add animation for column hiding.
    if column.issue_stats.blank?
      column.destroy
      render json: { result: true, message: "Column \"#{column.name}\" was successfully deleted.", id: column.id }
    else
      render json: { result: false, message: "Can't delete column with issues!" }
    end
    # NOTE : After 302 redirect board was deleted too! But with 303 page don't reload. :(
    #redirect_to board_url(@board), notice: message, status: 303
  end

  def move_left
    move_to(:left)
  end

  def move_right
    move_to(:right)
  end

  def wip
    @settings = WipColumnSettings.new(column_settings)
    @settings.save_to(@board.columns.find(params[:id]))
    redirect_to board_url(@board), notice: 'Column WIP limit successfully updated.'
  end

  # FIX : Extract settings as a Model
  def update_settings
    column = @board.columns.find(params[:id])
    settings = column.wip_settings
    settings.send("#{params[:name]}=", params[:value].empty? ? nil : params[:value])
    column.wip_settings = settings
    column.save!
    render nothing: true
  end

  private

  def move_to(direction)
    transporter = ColumnTransporter.new(@board.columns.find(params[:id]))
    if transporter.can_move?
      notice = 'Column was successfully moved'
      transporter.send("move_#{direction}")
    else
      notice = 'Can\'t move column with issues!'
    end
    redirect_to board_url(@board), notice: notice
  end

  def column_params
    params
      .require(:column)
      .permit(:name, :issues)
  end

  def column_settings
    params.
      require(:wip_column_settings).
      permit(:min, :max)
  end

  def fetch_resource
    @board.columns.find(params[:id])
  end

  def render_result
    render json: { redirect_url: board_url(@board), notice: 'Column was successfully updated' }
  end
end
