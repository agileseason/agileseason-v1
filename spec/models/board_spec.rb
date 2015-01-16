describe Board, type: :model do
  describe :validates do
    subject { Board.new }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :type }
    it { is_expected.to validate_presence_of :columns }
  end

  describe '.github_labels' do
    let(:column_1) { build(:column, name: "backlog", order: 1) }
    let(:column_2) { build(:column, name: "todo", order: 2) }
    let(:board) { build(:board, columns: [column_1, column_2]) }
    subject { board.github_labels }
    it { is_expected.to eq ["[1] backlog", "[2] todo"] }
  end

  describe '.to_param' do
    let(:board) { build(:board, github_name: 'agileseason') }
    subject { board.to_param }

    it { is_expected.to eq board.github_name }
  end

  describe 'check issue_stats order - important for workers' do
    let(:board) { create(:board, :with_columns) }
    let!(:stat_1) { create(:issue_stat, board: board, number: 2) }
    let!(:stat_2) { create(:issue_stat, board: board, number: 1) }
    subject { board.issue_stats }
    it { is_expected.to eq [stat_2, stat_1] }
  end
end
