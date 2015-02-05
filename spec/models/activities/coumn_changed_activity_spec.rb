describe Activities::ColumnChangedActivity, type: :model do
  describe '.create_for' do
    subject { Activities::ColumnChangedActivity.create_for(issue_stat, column_from, column_to, user) }
    let(:user) { build_stubbed(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    let(:issue_stat) { create(:issue_stat, board: board) }
    let(:column_from) { 'todo' }
    let(:column_to) { 'progress' }

    it { expect { subject }.to change(Activities::ColumnChangedActivity, :count).by(1) }
    it { expect(subject.board).to eq board }
    it { expect(subject.issue_stat).to eq issue_stat }
    it { expect(subject.data).to eq({ column_from: column_from, column_to: column_to }) }
  end
end
