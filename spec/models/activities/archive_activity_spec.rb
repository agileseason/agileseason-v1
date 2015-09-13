describe Activities::ArchiveActivity, type: :model do
  describe '.create_for' do
    subject { Activities::ArchiveActivity.create_for(issue_stat, user) }
    let(:board) { create(:board_with_columns, user: user) }
    let(:issue_stat) { create(:issue_stat, board: board) }

    context 'with user' do
      let(:user) { create(:user) }

      it { expect { subject }.to change(Activities::ArchiveActivity, :count).by(1) }
      it { expect(subject.board).to eq board }
      it { expect(subject.issue_stat).to eq issue_stat }
      it { expect(subject.data).to be_nil }
    end

    context 'without user' do
      let(:user) {}
      it { expect { subject }.not_to change(Activities::ArchiveActivity, :count) }
    end
  end
end
