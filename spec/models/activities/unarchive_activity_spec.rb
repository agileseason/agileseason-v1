describe Activities::UnarchiveActivity, type: :model do
  describe '.create_for' do
    subject { Activities::UnarchiveActivity.create_for(issue_stat, user) }
    let(:user) { build(:user) }
    let(:board) { build(:kanban_board, :with_columns, user: user) }
    let(:issue_stat) { build(:issue_stat, board: board) }

    it { expect { subject }.to change(Activities::UnarchiveActivity, :count).by(1) }
    its(:board) { is_expected.to eq board }
    its(:issue_stat) { is_expected.to eq issue_stat }
    its(:data) { is_expected.to be_nil }
  end
end
