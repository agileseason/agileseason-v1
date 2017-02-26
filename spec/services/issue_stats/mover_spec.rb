describe IssueStats::Mover do
  let(:user) { build(:user) }
  let(:board) { build(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }
  let(:issue) { stub_issue }
  let(:github_api) { double(issue: issue) }
  before { allow(user).to receive(:github_api).and_return(github_api) }
  before { allow(IssueStats::Unready).to receive(:call) }

  before { allow(IssueStats::AutoAssigner).to receive(:call) }
  before { allow(IssueStats::AutoCloser).to receive(:call) }
  before { allow(IssueStats::Sorter).to receive(:call) }

  describe '#call' do
    subject do
      IssueStats::Mover.call(
        user: user,
        board_bag: board_bag,
        column_to: column_to,
        number: number
      )
    end
    let(:number) { issue_stat.number }
    let(:issue_stat) { create(:issue_stat, number: stub_issue.number, board: board, column: column_from) }

    context 'column not changed' do
      let(:column_from) { board.columns.first }
      let(:column_to) { board.columns.first }

      its(:column) { is_expected.to eq column_from }
      it { expect { subject }.to change(Activity, :count).by(0) }

      context 'behavior' do
        before { subject }
        it { expect(IssueStats::Unready).not_to have_received(:call) }
        it { expect(IssueStats::AutoAssigner).to have_received(:call) }
        it { expect(IssueStats::AutoCloser).to have_received(:call) }
        it { expect(IssueStats::Sorter).to have_received(:call) }
      end
    end

    context 'column changed' do
      let(:column_from) { board.columns.first }
      let(:column_to) { board.columns.second }

      let(:is_force_sort) { false }

      it { expect { subject }.to change(Activity, :count).by(1) }
      its(:column) { is_expected.to eq column_to }

      context 'behavior' do
        before { subject }
        it { expect(IssueStats::Unready).to have_received(:call) }
        it { expect(IssueStats::AutoAssigner).to have_received(:call) }
        it { expect(IssueStats::AutoCloser).to have_received(:call) }
        it { expect(IssueStats::Sorter).to have_received(:call) }
      end
    end
  end
end
