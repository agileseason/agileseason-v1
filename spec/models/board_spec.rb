RSpec.describe Board, type: :model do
  describe :validates do
    subject { Board.new }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :type }
    it { is_expected.to validate_presence_of :columns }
  end

  describe ".github_labels" do
    let(:column_1) { build(:column, name: "backlog", order: 1) }
    let(:column_2) { build(:column, name: "todo", order: 2) }
    let(:board) { build(:board, columns: [column_1, column_2]) }
    subject { board.github_labels }
    it { is_expected.to eq ["[1] backlog", "[2] todo"] }
  end
end
