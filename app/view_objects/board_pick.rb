class BoardPick
  delegate :id, :name, to: :@board

  pattr_initialize :board

  def link
    Rails.application.routes.url_helpers.board_path(@board)
  end

  def issues_count
    "#{@board.issue_stats.open.count} open issues"
  end

  def self.default
    OpenStruct.new(
      id: nil,
      name: 'New Board...',
      link: Rails.application.routes.url_helpers.repos_path,
      issues_count: '&nbsp;',
    )
  end

  def self.list_by(boards)
    boards.map { |board| BoardPick.new(board) } << BoardPick.default
  end

  def self.public_list
    Board.
      where(is_public: true).
      map { |board| BoardPick.new(board) }
  end
end
