class BoardPick
  delegate :id, :name, to: :@board

  DEFAULT = OpenStruct.new(
    id: nil,
    name: 'New Board...',
    link: UrlGenerator.repos_path,
    issues_count: '&nbsp;',
  ).freeze

  pattr_initialize :board

  def link
    Rails.application.routes.url_helpers.board_path(@board)
  end

  def issues_count
    "#{@board.issue_stats.open.count} open issues"
  end

  def self.list_by(user, boards)
    board_picks = boards.map { |board| BoardPick.new(board) }
    board_picks << DEFAULT unless user.guest?
    board_picks
  end

  def self.public_list
    Board.
      where(is_public: true).
      map { |board| BoardPick.new(board) }
  end
end
