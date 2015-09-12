describe IssueStatService do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  let(:service) { IssueStatService }

  pending '.create'

  describe '.set_due_date' do
    subject { service.set_due_date(user, board, number, new_due_date) }
    let!(:issue_stat) do
      create(
        :issue_stat,
        board: board,
        number: number,
        due_date_at: due_date_at
      )
    end
    let(:number) { 1 }
    let(:due_date_at) { nil }

    context 'check data' do
      before do
        allow(Activities::ChangeDueDate).
          to receive(:create_for)
      end

      context 'from nil to nil' do
        let(:new_due_date) { nil }
        it { expect(subject.due_date_at).to be_nil }
      end

      context 'from nil to due_date' do
        let(:new_due_date) { DateTime.now }
        it { expect(subject.due_date_at).to eq new_due_date }
      end

      context 'from due_date to new due_date' do
        let(:due_date_at) { DateTime.now }
        let(:new_due_date) { DateTime.yesterday }

        it { expect(subject.due_date_at).to eq new_due_date }
      end

      context 'from due_date to nil' do
        let(:due_date_at) { DateTime.now }
        let(:new_due_date) { nil }

        it { expect(subject.due_date_at).to be_nil }
      end
    end

    context 'call create activity' do
      let(:new_due_date) { DateTime.now }
      after { subject }

      it do
        expect(Activities::ChangeDueDate).
          to receive(:create_for).with(issue_stat, user)
      end
    end
  end

  describe '.find_or_build_issue_stat' do
    subject { service.find_or_build_issue_stat(board, issue) }
    let(:issue) { stub_issue }

    it { is_expected.not_to be_nil }
    it { is_expected.not_to be_persisted }
    its(:board_id) { is_expected.to eq board.id }
    its(:number) { is_expected.to eq issue.number }
  end
end
