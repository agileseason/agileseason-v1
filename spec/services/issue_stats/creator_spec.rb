describe IssueStats::Creator do
  let(:creator) { IssueStats::Creator.new(user, board_bag, issue) }
  let(:user) { build(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }
  let(:github_api) { double(create_issue: issue) }
  let(:issue) { stub_issue(color: color, column_id: column_id) }
  let(:color) { '#dcedc8' }
  let(:column_id) { nil }
  before { allow(user).to receive(:github_api).and_return(github_api) }

  describe '#call' do
    subject { creator.call }
    before { allow(IssueStats::AutoAssigner).to receive(:call) }
    before { allow(IssueStats::Sorter).to receive(:call) }
    before { allow(board_bag).to receive(:update_cache) }

    its(:issue_stat) { is_expected.to be_persisted }
    its(:number) { is_expected.to eq issue.number }
    its(:created_at) { is_expected.to eq issue.created_at }
    its(:updated_at) { is_expected.to eq issue.updated_at }
    its(:closed_at) { is_expected.to eq issue.closed_at }
    its(:column) { is_expected.to eq board.columns.first }
    its(:color) { is_expected.to eq issue.color }
    it { is_expected.to be_a(BoardIssue) }

    context 'with specific column_id' do
      let(:issue) { stub_issue(column_id: column_id) }
      let(:column_id) { board.columns.second.id }

      its(:column) { is_expected.to eq board.columns.second }
    end

    context 'behavior' do
      before { subject }

      it { expect(IssueStats::AutoAssigner).to have_received(:call) }
      it { expect(IssueStats::Sorter).to have_received(:call) }
      it { expect(github_api).to have_received(:create_issue).with(board_bag, issue) }
      it { expect(board_bag).to have_received(:update_cache).with(issue) }
    end
  end
end
