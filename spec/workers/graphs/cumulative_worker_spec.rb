describe Graphs::CumulativeWorker do
  let(:worker) { Graphs::CumulativeWorker.new }

  describe '.perform' do
    subject { board.board_histories }
    let(:user) { create(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    let(:column_1) { board.columns.first }
    let(:column_2) { board.columns.second }
    let(:perform) { worker.perform(board.id, Encryptor.encrypt('fake_token')) }
    let(:issue) { BoardIssue.new(nil, issue_stat) }
    let(:issue_stat) { build(:issue_stat) }
    before do
      allow_any_instance_of(BoardBag).
        to receive(:issues_by_columns).and_return(issues_by_columns)
    end
    before { perform }

    context :create_board_history do
      context :one_issue do
        let(:issues_by_columns) { { column_1.id => [issue] } }
        let(:expected_data) do
          [
            { column_id: column_1.id, issues: 1, issues_cumulative: 1 },
            { column_id: column_2.id, issues: 0, issues_cumulative: 0 },
          ]
        end
        it { expect(subject.first.data).to eq expected_data }
      end

      context :two_issues do
        let(:issues_by_columns) { { column_1.id => [issue, issue] } }
        let(:expected_data) do
          [
            { column_id: column_1.id, issues: 2, issues_cumulative: 2 },
            { column_id: column_2.id, issues: 0, issues_cumulative: 0 },
          ]
        end
        it { expect(subject.first.data).to eq expected_data }
      end
    end

    context 'ignore archive issues' do
      let(:issues_by_columns) { { column_2.id => [issue] } }
      let(:issue) { BoardIssue.new(nil, issue_stat) }
      let(:issue_stat) { build(:issue_stat, :archived) }
      let(:expected_data) do
        [
          { column_id: column_1.id, issues: 0, issues_cumulative: 0 },
          { column_id: column_2.id, issues: 0, issues_cumulative: 0 },
        ]
      end

      it { expect(subject.first.data).to eq expected_data }
    end

    context 'sum previous archive issues from board' do
      let(:issues_by_columns) { { column_2.id => [issue] } }
      let(:issue) { BoardIssue.new(nil, issue_stat) }
      let(:issue_stat) { create(:issue_stat, :archived, board: board) }
      let(:expected_data) do
        [
          { column_id: column_1.id, issues: 0, issues_cumulative: 1 },
          { column_id: column_2.id, issues: 0, issues_cumulative: 1 },
        ]
      end

      it { expect(subject.first.data).to eq expected_data }
    end
  end
end
