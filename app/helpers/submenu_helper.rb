module SubmenuHelper
  include UrlHelper

  def submenu
    [
      OpenStruct.new(
        name: 'Cumulative Flow Diagram',
        controller: 'graphs/cumulative',
        url: board_graphs_cumulative_index_url(@board)
      ),
      OpenStruct.new(
        name: 'Control Chart',
        controller: 'graphs/control',
        url: board_graphs_control_index_url(@board)
      ),
      OpenStruct.new(
        name: 'Cycle Time Diagram',
        controller: 'graphs/frequency',
        url: board_graphs_frequency_index_url(
          @board,
          from: date_to_url(@board.created_at)
        )
      ),
      OpenStruct.new(
        name: 'Age of Issues',
        controller: 'graphs/age',
        url: board_graphs_age_index_url(@board)
      ),
      OpenStruct.new(
        name: 'Lines of Code',
        controller: 'graphs/lines',
        url: board_graphs_lines_url(@board)
      )
    ]
  end
end
