RSpec.describe Graphs::CumulativeWorker do
  let(:worker) { Graphs::CumulativeWorker.new }

  describe '.perform' do
    subject { board.board_histories }
    let(:board) { create(:board, :with_columns) }
    let(:column) { board.columns.first }
    let(:perform) { worker.perform(board.id, 'fake_github_token') }
    let(:issue) { BoardIssue.new(nil, nil) }
    before { allow_any_instance_of(GithubApi).to receive(:board_issues).and_return(board_issues) }
    before { perform }

    context :create_board_history do
      context :one_issue do
        let(:board_issues) { { column.id => [issue] } }
        let(:expected_data) { [{ column_id: column.id, issues: 1, issues_cumulative: 1 }] }
        it { is_expected.to have(1).item }
        it { expect(subject.first.data).to eq expected_data }
      end

      context :two_issues do
        let(:board_issues) { { column.id => [issue, issue] } }
        let(:expected_data) { [{ column_id: column.id, issues: 2, issues_cumulative: 2 }] }
        it { is_expected.to have(1).item }
        it { expect(subject.first.data).to eq expected_data }
      end
    end
  end
end
