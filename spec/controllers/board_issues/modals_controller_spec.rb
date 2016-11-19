describe BoardIssues::ModalsController do
  describe '#show' do
    subject do
      get(:show, params: {
        board_github_full_name: board.github_full_name,
        number: issue.number
      })
    end
    let(:issue) { stub_issue }
    let(:board) { create(:kanban_board, :with_columns) }
    let(:board_issue) { BoardIssue.new(issue, issue_stat) }
    let(:issue_stat) { create(:issue_stat, number: issue.number, board: board) }
    before { allow(Boards::DetectRepo).to receive(:call).and_return(stub_repo) }
    before { allow_any_instance_of(BoardBag).to receive(:labels).and_return([]) }
    before do
      allow_any_instance_of(BoardBag).to receive(:issue).and_return(board_issue)
    end
    before { subject }

    it { expect(response).to have_http_status(:success) }
  end
end
