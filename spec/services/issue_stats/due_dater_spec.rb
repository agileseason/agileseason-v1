describe IssueStats::DueDater do
  let(:user) { build(:user) }
  let(:board) { build(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }

  describe '#call' do
    subject do
      IssueStats::DueDater.call(
        user: user,
        board_bag: board_bag,
        number: issue_stat.number,
        due_date_at: due_date_at
      )
    end
    let(:issue_stat) { create(:issue_stat, board: board, due_date_at: old_due_date_at) }
    before { allow(Activities::ChangeDueDate).to receive(:create_for) }

    context 'from nil to nil' do
      let(:due_date_at) { nil }
      let(:old_due_date_at) { nil }

      its(:due_date_at) { is_expected.to be_nil }
    end

    context 'from nil to due_date' do
      let(:old_due_date_at) { nil }
      let(:due_date_at) { DateTime.now }

      its(:due_date_at) { is_expected.to eq due_date_at }
    end

    context 'from due_date to new due_date' do
      let(:old_due_date_at) { DateTime.now }
      let(:due_date_at) { DateTime.yesterday }

      its(:due_date_at) { is_expected.to eq due_date_at }
    end

    context 'from due_date to nil' do
      let(:old_due_date_at) { DateTime.now }
      let(:due_date_at) { nil }

      its(:due_date_at) { is_expected.to be_nil }
    end

    describe 'behavior' do
      let(:old_due_date_at) { nil }
      let(:due_date_at) { DateTime.now }
      before { subject }

      it do
        expect(Activities::ChangeDueDate).
          to have_received(:create_for).with(issue_stat, user)
      end
    end
  end
end
