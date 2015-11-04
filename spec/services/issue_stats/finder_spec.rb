describe IssueStats::Finder do
  let(:finder) { IssueStats::Finder.new(user, board_bag, number) }
  let(:user) { build(:user) }
  let(:board) { build(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }
  let(:number) { 101 }

  describe '#call' do
    subject { finder.call }

    context 'issue_stat exists' do
      before { create(:issue_stat, number: number, board: board) }
      after { subject }

      it { expect(IssueStatService).not_to receive(:create) }
    end

    context 'issue_stat does not exiests' do
      let(:issue) { stub_issue(number: number) }
      before { allow(finder).to receive(:github_issue).and_return(issue) }
      after { subject }

      it { expect(IssueStatService).to receive(:create).with(board_bag, issue) }
    end
  end
end
