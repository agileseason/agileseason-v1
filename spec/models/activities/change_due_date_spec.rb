describe Activities::ChangeDueDate, type: :model do
  describe '.create_for' do
    subject { Activities::ChangeDueDate.create_for(issue_stat, user) }
    let(:user) { create(:user) }
    let(:board) { create(:board_with_columns, user: user) }
    let(:issue_stat) { create(:issue_stat, board: board, due_date_at: due_date_at) }
    let(:due_date_at) { DateTime.now }

    it { expect { subject }.to change(Activities::ChangeDueDate, :count).by(1) }
    it { expect(subject.board).to eq board }
    it { expect(subject.issue_stat).to eq issue_stat }
    it { expect(subject.data).to eq(due_date_at: due_date_at) }
  end

  describe '#description' do
    subject { activity.description }
    let(:activity) { create(:change_due_date_acivity, data: data) }
    let(:data) { { due_date_at: due_date_at } }

    context 'with due date' do
      let(:due_date_at) { DateTime.now }
      it { is_expected.to eq "changed due date to - #{due_date_at.strftime('%b %d %H:%M')}" }
    end

    context 'without due date' do
      let(:due_date_at) { nil }
      it { is_expected.to eq 'changed due date to - nil' }
    end

    context 'without data' do
      let(:data) { nil }
      it { is_expected.to eq 'changed due date to - nil' }
    end
  end
end
