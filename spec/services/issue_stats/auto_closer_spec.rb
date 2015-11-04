describe IssueStats::AutoCloser do
  let(:user) { build(:user) }
  let(:board) { build(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }
  let(:issue) { stub_issue }
  let(:github_api) { double(issue: issue) }
  before { allow(user).to receive(:github_api).and_return(github_api) }
  before { allow(IssueStats::Closer).to receive(:call) }

  describe '#call' do
    subject do
      IssueStats::AutoCloser.call(
        user: user,
        board_bag: board_bag,
        column: column,
        number: issue.number
      )
    end
    let(:column) { board.columns.first }
    before { column.update(is_auto_close: is_auto_close) }
    before { subject }

    context 'column without auto-close' do
      let(:is_auto_close) { false }
      it { expect(IssueStats::Closer).not_to have_received(:call) }
    end

    context 'column with auto-close' do
      let(:is_auto_close) { true }

      context 'issue closed' do
        let(:issue) { stub_closed_issue }
        it { expect(IssueStats::Closer).not_to have_received(:call) }
      end

      context 'issue opened' do
        it do
          expect(IssueStats::Closer).
            to have_received(:call).
            with(
              user: user,
              board_bag: board_bag,
              number: issue.number
            )
        end
      end
    end
  end
end
