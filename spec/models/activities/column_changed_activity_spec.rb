describe Activities::ColumnChangedActivity, type: :model do
  describe '.create_for' do
    subject { Activities::ColumnChangedActivity.create_for(issue_stat, column_from, column_to, user) }
    let(:board) { create(:board_with_columns, user: user) }
    let(:issue_stat) { create(:issue_stat, board: board) }
    let(:column_from) { build(:column, name: 'todo') }
    let(:column_to) { build(:column, name: 'progress') }

    context 'with user' do
      let(:user) { create(:user) }

      it { expect { subject }.to change(Activities::ColumnChangedActivity, :count).by(1) }
      it { expect(subject.board).to eq board }
      it { expect(subject.issue_stat).to eq issue_stat }
      it { expect(subject.data).to eq(column_from: column_from.name, column_to: column_to.name) }
    end

    context 'without user' do
      let(:user) { }
      it { expect { subject }.not_to change(Activities::ColumnChangedActivity, :count) }
    end
  end
end
