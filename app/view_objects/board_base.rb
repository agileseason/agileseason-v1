class BoardBase
  delegate :id, :name, to: :@board

  def initialize(board)
    @board = board
  end

  def link
    BoardBase.url_helpers.board_path(@board)
  end

  def issues_count
    "#{@board.issue_stats_on_board.count} issues"
  end

  private

  def self.default
    OpenStruct.new(
      id: nil,
      name: 'New Board...',
      link: url_helpers.repos_path,
      issues_count: '&nbsp;',
    )
  end

  def self.url_helpers
    Rails.application.routes.url_helpers
  end
end
