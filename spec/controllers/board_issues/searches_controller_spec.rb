describe BoardIssues::SearchesController do
  describe '#show' do
    subject do
      get(:show, params: {
        board_github_full_name: board.github_full_name,
        query: 'test'
      })
    end
    let(:board) { create(:kanban_board, :with_columns) }
    before do
      allow_any_instance_of(GithubApi).to receive(:search_issues).and_return([])
    end
    before { allow(controller).to receive(:ui_event) }
    before { subject }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template(partial: '_search_result') }
    it { expect(controller).to have_received(:ui_event).with(:issue_search) }
  end
end
