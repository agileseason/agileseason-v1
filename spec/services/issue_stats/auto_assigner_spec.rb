describe IssueStats::AutoAssigner do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }
  let(:column) { board.columns.first }
  let(:github_api) { double(issue: issue, assign: issue) }
  let(:issue) { stub_issue }
  before { allow(user).to receive(:github_api).and_return(github_api) }

  describe '#call' do
    subject do
      IssueStats::AutoAssigner.call(
        user: user,
        board_bag: board_bag,
        column: column,
        number: issue.number
      )
    end
    before { allow(board_bag).to receive(:update_cache) }
    before { column.update(is_auto_assign: is_auto_assign) }
    before { subject }

    context 'column without auto_assign' do
      let(:is_auto_assign) { false }

      it { expect(github_api).not_to have_received(:assign) }
      it { expect(board_bag).not_to have_received(:update_cache) }
    end

    context 'column with auto_assign' do
      let(:is_auto_assign) { true }

      context 'user already assigned' do
        let(:issue) { stub_issue(assignee: Object.new) }

        it { expect(github_api).not_to have_received(:assign) }
        it { expect(board_bag).not_to have_received(:update_cache) }
      end

      context 'user has not been assigned yet' do
        it { expect(github_api).to have_received(:assign) }
        it { expect(board_bag).to have_received(:update_cache) }
      end
    end
  end
end
