describe Activities::ArchiveActivity, type: :model do
  describe '.create_for' do
    subject { Activities::ArchiveActivity.create_for(issue_stat, user) }
    let(:board) { build(:board_with_columns, user: user) }
    let(:issue_stat) { build(:issue_stat, board: board) }

    context 'with user' do
      let(:user) { build(:user) }

      it { expect { subject }.to change(Activities::ArchiveActivity, :count).by(1) }
      its(:board) { is_expected.to eq board }
      its(:issue_stat) { is_expected.to eq issue_stat }
      its(:data) { is_expected.to be_nil }
    end

    context 'without user' do
      let(:user) {}
      it { expect { subject }.not_to change(Activities::ArchiveActivity, :count) }
    end
  end
end
