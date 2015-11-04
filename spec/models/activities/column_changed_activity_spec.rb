describe Activities::ColumnChangedActivity, type: :model do
  describe '.create_for' do
    subject { Activities::ColumnChangedActivity.create_for(issue_stat, column_from, column_to, user) }
    let(:board) { build(:board_with_columns, user: user) }
    let(:issue_stat) { build(:issue_stat, board: board) }
    let(:column_from) { build(:column, name: 'todo') }
    let(:column_to) { build(:column, name: 'progress') }

    context 'with user' do
      let(:user) { build(:user) }

      it { expect { subject }.to change(Activities::ColumnChangedActivity, :count).by(1) }
      its(:board) { is_expected.to eq board }
      its(:issue_stat) { is_expected.to eq issue_stat }
      its(:data) { is_expected.to eq(column_from: column_from.name, column_to: column_to.name) }
    end

    context 'without user' do
      let(:user) {}
      it { expect { subject }.not_to change(Activities::ColumnChangedActivity, :count) }
    end
  end
end
