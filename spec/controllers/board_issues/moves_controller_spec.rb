describe BoardIssues::MovesController do
  let(:user) { create(:user) }
  let(:board) { create(:kanban_board, :with_columns, user: user) }
  let(:number) { 1 }
  let(:column_to) { board.columns.first }
  let(:issue_stat) do
    create(:issue_stat, number: number, board: board, column: column_to)
  end
  let(:issue) { stub_issue(number: number) }
  before { stub_sign_in(user) }
  before { allow(controller).to receive(:broadcast_column) }
  before { allow(Cached::Issues).to receive(:call).and_return(issue.number => issue) }
  before { allow(Boards::DetectRepo).to receive(:call).and_return(stub_repo) }
  before do
    allow_any_instance_of(IssueStats::Finder).
      to receive(:call).
      and_return(issue_stat)
  end
  before { allow(IssueStats::Mover).to receive(:call).and_return(issue_stat) }

  describe '#update' do
    subject do
      patch(
        :update,
        params: {
          board_github_full_name: board.github_full_name,
          number: number,
          column_id: column_to.id
        }
      )
    end

    before { subject }
    it { expect(response).to have_http_status(:success) }
    it { expect(IssueStats::Mover).to have_received(:call) }
  end
end
