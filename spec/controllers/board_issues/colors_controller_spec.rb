describe BoardIssues::ColorsController do
  let(:issue) { stub_issue }
  let(:user) { create(:user) }
  let(:board) { create(:kanban_board, :with_columns, user: user) }
  before { stub_sign_in(user) }

  describe '#update' do
    subject do
      patch(
        :update,
        params: {
          board_github_full_name: board.github_full_name,
          number: issue.number,
          issue: { color: color }
        }
      )
    end
    let(:color) { '#ffffff' }
    let(:issue_stat) { build(:issue_stat, board: board, column: column_1) }
    let(:column_1) { board.columns.first }
    before { allow(IssueStats::Painter).to receive(:call).and_return(issue_stat) }
    before { allow(controller).to receive(:broadcast_column) }
    before { allow(controller).to receive(:render_board_issue_json).and_return({}) }
    before { subject }

    it { expect(response).to have_http_status(:success) }
    it do
      expect(IssueStats::Painter).
        to have_received(:call).with(
          user: user,
          board_bag: anything,
          number: issue.number,
          color: color
        )
    end
    it { expect(controller).to have_received(:broadcast_column).with(column_1) }
  end
end
