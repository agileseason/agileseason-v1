describe IssueStats::Unarchiver do
  let(:unarchiver) { IssueStats::Unarchiver.new(user, board_bag, issue_stat.number) }
  let(:user) { build(:user) }
  let(:board) { build(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }

  describe '#call' do
    subject { unarchiver.call }

    context 'issue not archived yet' do
      let(:issue_stat) { create(:issue_stat, board: board) }

      context 'behavior' do
        after { subject }

        it { expect(Activities::UnarchiveActivity).not_to receive(:create_for) }
        it { expect_any_instance_of(Lifetimes::Starter).not_to receive(:call) }
      end
    end

    context 'archived issue' do
      let(:issue_stat) { create(:issue_stat, :archived, board: board) }

      context 'behavior' do
        after { subject }

        it { expect(Activities::UnarchiveActivity).to receive(:create_for) }
        it { expect_any_instance_of(Lifetimes::Starter).to receive(:call) }
      end

      context 'result' do
        before { subject }

        it { is_expected.not_to be_nil }
        it { expect(issue_stat.reload).not_to be_archived }
      end
    end
  end
end
