describe IssueStats::Reopener do
  let(:reopener) { IssueStats::Reopener.new(user, board_bag, issue.number) }
  let(:user) { build(:user) }
  let(:board) { build(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }
  let(:github_api) { double(reopen: issue) }
  let(:issue) { stub_closed_issue }
  let!(:issue_stat) { create(:issue_stat, closed_at: issue.closed_at, board: board, number: issue.number) }
  before { allow(user).to receive(:github_api).and_return(github_api) }
  before { allow(board_bag).to receive(:update_cache) }

  describe '#call' do
    subject { reopener.call }

    its(:closed_at) { is_expected.to be_nil }

    context 'behavior' do
      after { subject }
      it { expect(board_bag).to receive(:update_cache).with(issue) }
      it { expect(github_api).to receive(:reopen).with(board_bag, issue.number) }
    end
  end
end
