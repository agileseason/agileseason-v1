describe Activities::UnarchiveActivity, type: :model do
  describe '.create_for' do
    subject { Activities::UnarchiveActivity.create_for(issue_stat, user) }
    let(:user) { create(:user) }
    let(:board) { create(:kanban_board, :with_columns, user: user) }
    let(:issue_stat) { create(:issue_stat, board: board) }

    it { expect { subject }.to change(Activities::UnarchiveActivity, :count).by(1) }
    it { expect(subject.board).to eq board }
    it { expect(subject.issue_stat).to eq issue_stat }
    it { expect(subject.data).to be_nil }
  end
end
