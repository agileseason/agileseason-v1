RSpec.describe Graphs::CumulativeWorker do
  let(:worker) { Graphs::CumulativeWorker.new }

  describe '.perform' do
    subject { board.board_histories }
    let(:board) { create(:board, :with_columns) }
    let(:column_1) { board.columns.first }
    let(:column_2) { board.columns.second }
    let(:perform) { worker.perform(board.id, Encryptor.encrypt('fake_token')) }
    let(:issue) { BoardIssue.new(nil, nil) }
    before do
      allow_any_instance_of(GithubApi).
        to receive(:board_issues).and_return(board_issues)
    end
    before { perform }

    context :create_board_history do
      context :one_issue do
        let(:board_issues) { { column_1.id => [issue] } }
        let(:expected_data) do
          [
            { column_id: column_1.id, issues: 1, issues_cumulative: 1 },
            { column_id: column_2.id, issues: 0, issues_cumulative: 0 },
          ]
        end
        it { is_expected.to have(1).item }
        it { expect(subject.first.data).to eq expected_data }
      end

      context :two_issues do
        let(:board_issues) { { column_1.id => [issue, issue] } }
        let(:expected_data) do
          [
            { column_id: column_1.id, issues: 2, issues_cumulative: 2 },
            { column_id: column_2.id, issues: 0, issues_cumulative: 0 },
          ]
        end
        it { is_expected.to have(1).item }
        it { expect(subject.first.data).to eq expected_data }
      end
    end
  end
end
