describe Graphs::CfdSnapshot do
  describe 'call' do
    subject { Graphs::CfdSnapshot.call(board: board) }
    let(:board) { create(:board, :with_columns) }
    let(:column_1) { board.columns.first }
    let(:column_2) { board.columns.second }

    context 'without issue stats' do
      let(:expected_1) { { column_id: column_1.id, issues: 0, issues_cumulative: 0 } }
      let(:expected_2) { { column_id: column_2.id, issues: 0, issues_cumulative: 0 } }

      its(:size) { is_expected.to eq board.columns.size }
      its(:first) { is_expected.to eq expected_1 }
      its(:second) { is_expected.to eq expected_2 }
    end

    context 'wit issue stats' do
      let(:expected_1) { { column_id: column_1.id, issues: 1, issues_cumulative: 3 } }
      let(:expected_2) { { column_id: column_2.id, issues: 2, issues_cumulative: 2 } }
      before do
        create(:issue_stat, board: board, column: column_1)
        create(:issue_stat, :closed, board: board, column: column_2)
        create(:issue_stat, :archived, board: board, column: column_2)
      end

      its(:size) { is_expected.to eq board.columns.size }
      its(:first) { is_expected.to eq expected_1 }
      its(:second) { is_expected.to eq expected_2 }
    end
  end
end
