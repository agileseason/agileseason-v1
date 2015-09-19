json.content render('columns/settings_on_board',
  formats: :html, board: @board, column: @board_bag.columns.find(params[:id])
)
