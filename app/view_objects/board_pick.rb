class BoardPick
  delegate :id, :name, :persisted?, to: :@board
  delegate :url_helpers, to: 'Rails.application.routes'

  DEFAULT = OpenStruct.new(
    id: nil,
    name: 'New Board...',
    link: '/repos',
    issues_count: '&nbsp;',
    settings_url: '#',
    html_class: :new,
    owner: nil
  ).freeze

  pattr_initialize :board

  def link
    url_helpers.board_path(@board)
  end

  def settings_url
    url_helpers.board_settings_path(@board)
  end

  def issues_count
    "#{@board.issue_stats.open.count} open issues"
  end

  def html_class
    return :public if @board.public?
    :normal
  end

  def owner
    @board.user
  end

  def self.list_by(user, boards)
    board_picks = boards.map { |board| BoardPick.new(board) }
    board_picks << DEFAULT unless user.guest?
    board_picks
  end

  def self.public_list
    Board.
      where(is_public: true).
      map { |board| BoardPick.new(board) }.
      sort_by(&:name)
  end
end
