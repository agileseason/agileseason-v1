describe IssueStats::Assigner do
  let(:user) { build(:user) }
  let(:board) { build(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(user, board) }
  let(:github_api) { double(assign: issue) }
  let(:issue) { stub_issue }
  let(:login) { 'test_github_username' }
  before { allow(user).to receive(:github_api).and_return(github_api) }
  before { allow(board_bag).to receive(:update_cache) }
  before { create(:issue_stat, number: issue.number, board: board) }

  describe '#call' do
    subject do
      IssueStats::Assigner.call(
        user: user,
        board_bag: board_bag,
        number: issue.number,
        login: login
      )
    end

    it { is_expected.not_to be_nil }

    context 'behavior' do
      before { subject }

      it do
        expect(github_api).
          to have_received(:assign).with(board_bag, issue.number, login)
      end
      it { expect(board_bag).to have_received(:update_cache).with(issue) }
    end
  end
end
