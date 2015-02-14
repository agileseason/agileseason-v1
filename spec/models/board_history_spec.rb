RSpec.describe BoardHistory, type: :model do
  describe 'validates' do
    subject { BoardHistory.new }
    it { is_expected.to validate_presence_of(:collected_on) }
    it { is_expected.to validate_presence_of(:data) }
    it { is_expected.to validate_uniqueness_of(:collected_on) }
  end

  describe '.update_data_issues' do
    subject { history.update_data_issues(board_issues) }
    let(:history) { build(:board_history, board: board) }

    let(:board) { create(:board, :with_columns) }
    let(:column) { board.columns.first }
    let(:issue) { OpenStruct.new(name: 'issue_1') }
    let(:issue_stat) { create(:issue_stat, board: board, column: column) }
    let(:board_issue) { BoardIssue.new(issue, issue_stat) }

    context :one_column do
      let(:board_issues) { { column.id => [board_issue] } }
      let(:expected_data) { [{ column_id: column.id, issues: 1, issues_cumulative: 1 }] }

      it { is_expected.to eq expected_data }
    end

    context :two_columns do
      let(:board) { create(:board, :with_columns, number_of_columns: 2) }
      let(:board_issues) do
        board.columns.each_with_object({}) { |column, issues| issues[column.id] = [board_issue] }
      end

      it { is_expected.to have(2).items }
    end
  end
end
