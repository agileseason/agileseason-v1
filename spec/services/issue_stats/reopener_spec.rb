describe IssueStats::Reopener do
  subject do
    IssueStats::Reopener.call(
      user: user,
      board_bag: board_bag,
      number: issue.number
    )
  end
  let(:user) { build(:user) }
  let(:board) { build(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }
  let(:github_api) { double(reopen: issue) }
  let(:issue) { stub_closed_issue }
  before { allow(user).to receive(:github_api).and_return(github_api) }
  before { allow(board_bag).to receive(:update_cache) }

  describe '#call' do
    let!(:issue_stat) do
      create(:issue_stat, closed_at: issue.closed_at, board: board,
        number: issue.number)
    end

    its(:closed_at) { is_expected.to be_nil }

    context 'behavior' do
      before { subject }

      it { expect(board_bag).to have_received(:update_cache).with(issue) }
      it do
        expect(github_api).
          to have_received(:reopen).with(board_bag, issue.number)
      end
    end
  end
end
