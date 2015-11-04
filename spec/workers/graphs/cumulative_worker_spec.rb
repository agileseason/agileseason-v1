describe Graphs::CumulativeWorker do
  let(:worker) { Graphs::CumulativeWorker.new }

  describe '.perform' do
    subject { board.board_histories }
    let(:user) { build(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    let(:column_1) { board.columns.first }
    let(:column_2) { board.columns.second }
    let(:perform) { worker.perform(board.id, Encryptor.encrypt('fake_token')) }
    let(:issue_stats) {}
    before { allow(Boards::Synchronizer).to receive(:call) }
    before { issue_stats }
    before { perform }

    it { expect(Boards::Synchronizer).to have_received(:call) }

    context 'create_board_history' do
      context 'one_issue' do
        let(:issue_stats) do
          create(:issue_stat, board: board, column: column_1)
        end
        let(:expected_data) do
          [
            { column_id: column_1.id, issues: 1, issues_cumulative: 1 },
            { column_id: column_2.id, issues: 0, issues_cumulative: 0 },
          ]
        end
        it { expect(subject.first.data).to eq expected_data }
      end

      context 'two_issues' do
        let(:issue_stats) do
          create(:issue_stat, board: board, column: column_1)
          create(:issue_stat, board: board, column: column_1)
        end
        let(:expected_data) do
          [
            { column_id: column_1.id, issues: 2, issues_cumulative: 2 },
            { column_id: column_2.id, issues: 0, issues_cumulative: 0 },
          ]
        end
        it { expect(subject.first.data).to eq expected_data }
      end
    end

    context 'sum previous archive issues from board' do
      let(:issue_stats) do
        create(:issue_stat, board: board, column: column_1)
        create(:issue_stat, :archived, board: board, column: column_2)
      end
      let(:issue) { BoardIssue.new(nil, issue_stat) }
      let(:expected_data) do
        [
          { column_id: column_1.id, issues: 1, issues_cumulative: 2 },
          { column_id: column_2.id, issues: 1, issues_cumulative: 1 },
        ]
      end

      it { expect(subject.first.data).to eq expected_data }
    end
  end
end
