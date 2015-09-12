describe IssueStats::Closer do
  let(:closer) { IssueStats::Closer.new(user, board_bag, issue.number) }
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }
  let(:github_api) { double(close: issue) }
  let(:issue) { stub_closed_issue }
  let!(:issue_stat) { create(:issue_stat, board: board, number: issue.number) }
  before { allow(user).to receive(:github_api).and_return(github_api) }

  describe '#call' do
    subject { closer.call }

    its(:closed_at) { is_expected.to eq issue.closed_at }

    context 'behavior' do
      after { subject }
      it { expect(board_bag).to receive(:update_cache).with(issue) }
      it { expect(github_api).to receive(:close).with(board_bag, issue.number) }
    end
  end
end
