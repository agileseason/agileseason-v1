describe IssueStats::Unready do
  describe '#call' do
    subject { IssueStats::Unready.new(user, board_bag, number).call }
    let(:user) { create(:user) }
    let(:board_bag) { BoardBag.new(nil, board) }
    let(:number) { issue.number }
    let(:issue) { stub_issue }
    let(:board) { create(:board, :with_columns, user: user) }

    context 'issue_stat is exists' do
      before { create(:issue_stat, board: board, number: number, is_ready: is_ready_prev) }

      context 'is ready before' do
        let(:is_ready_prev) { true }
        its(:ready?) { is_expected.to eq false }
      end

      context 'is not ready before' do
        let(:is_ready_prev) { false }
        its(:ready?) { is_expected.to eq false }
      end
    end

    context 'issue_stat is not exists' do
      before { allow(user).to receive(:github_api).and_return(double(issue: issue)) }
      its(:ready?) { is_expected.to eq false }
    end
  end
end
