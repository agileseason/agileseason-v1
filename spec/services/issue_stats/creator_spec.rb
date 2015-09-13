describe IssueStats::Creator do
  let(:creator) { IssueStats::Creator.new(user, board_bag, issue) }
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }
  let(:github_api) { double(create_issue: issue) }
  let(:issue) { stub_issue }
  before { allow(user).to receive(:github_api).and_return(github_api) }

  describe '#call' do
    subject { creator.call }
    before { allow_any_instance_of(Lifetimes::Starter).to receive(:call) }
    before { allow_any_instance_of(IssueStats::Sorter).to receive(:call) }

    its(:issue_stat) { is_expected.to be_persisted }
    its(:number) { is_expected.to eq issue.number }
    its(:created_at) { is_expected.to eq issue.created_at }
    its(:updated_at) { is_expected.to eq issue.updated_at }
    its(:closed_at) { is_expected.to eq issue.closed_at }
    its(:column) { is_expected.to eq board.columns.first }

    context 'behavior' do
      after { subject }

      it { expect_any_instance_of(Lifetimes::Starter).to receive(:call) }
      it { expect_any_instance_of(IssueStats::Sorter).to receive(:call) }
      it { expect(github_api).to receive(:create_issue).with(board_bag, issue) }
      it { expect(board_bag).to receive(:update_cache).with(issue) }
    end
  end
end
