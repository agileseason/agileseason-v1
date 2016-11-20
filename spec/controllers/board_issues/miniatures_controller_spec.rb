describe BoardIssues::MiniaturesController do
  describe '#show' do
    subject do
      get(:show, params: {
        board_github_full_name: board.github_full_name,
        number: issue_stat.number
      })
    end
    let(:board) { create(:kanban_board, :with_columns) }
    let(:issue_stat) { create :issue_stat, board: board, number: issue.number }
    let(:issue) { stub_issue }
    before { allow_any_instance_of(BoardBag).to receive(:issue).and_return(issue) }
    before { subject }

    it { expect(response).to have_http_status(:success) }
  end
end
