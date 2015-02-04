describe Activities::ArchiveActivity, type: :model do
  describe '.create_for' do
    subject { Activities::ArchiveActivity.create_for(issue_stat, user) }
    let(:user) { build_stubbed(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    let(:issue_stat) { create(:issue_stat, board: board) }

    it { expect { subject }.to change(Activities::ArchiveActivity, :count).by(1) }
  end
end
