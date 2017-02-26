describe IssueStats::Unarchiver do
  let(:user) { build(:user) }
  let(:board) { build(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }

  describe '#call' do
    subject do
      IssueStats::Unarchiver.call(
        user: user,
        board_bag: board_bag,
        number: issue_stat.number
      )
    end

    context 'issue not archived yet' do
      let(:issue_stat) { create(:issue_stat, board: board) }

      context 'behavior' do
        after { subject }
        it { expect(Activities::UnarchiveActivity).not_to receive(:create_for) }
      end
    end

    context 'archived issue' do
      let(:issue_stat) { create(:issue_stat, :archived, board: board) }

      context 'behavior' do
        after { subject }
        it { expect(Activities::UnarchiveActivity).to receive(:create_for) }
      end

      context 'result' do
        before { subject }

        it { is_expected.not_to be_nil }
        it { expect(issue_stat.reload).not_to be_archived }
      end
    end
  end
end
