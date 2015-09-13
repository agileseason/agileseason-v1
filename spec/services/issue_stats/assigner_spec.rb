describe IssueStats::Assigner do
  let(:assigner) { IssueStats::Assigner.new(user, board_bag, issue.number, login) }
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(user, board) }
  let(:github_api) { double(assign: issue) }
  let(:issue) { stub_issue }
  let(:login) { 'test_github_username' }
  before { allow(user).to receive(:github_api).and_return(github_api) }
  before { create(:issue_stat, number: issue.number, board: board) }

  describe '#call' do
    subject { assigner.call }

    it { is_expected.not_to be_nil }

    context 'behavior' do
      after { subject }

      it { expect(github_api).to receive(:assign).with(board_bag, issue.number, login) }
      it { expect(board_bag).to receive(:update_cache).with(issue) }
    end
  end
end
