describe WebhooksController do
  before { allow(controller).to receive(:broadcast_column) }
  before { allow(controller).to receive(:trusted_request?).and_return(true) }
  before { allow(Cached::ReadIssues).to receive(:call).and_return(cached_issues) }
  before { allow(Cached::UpdateIssues).to receive(:call) }

  describe '#github' do
    subject { get :github, params }
    let(:params) { { repository: repo, issue: issue_params } }
    let(:repo) { { full_name: board.github_full_name } }
    let(:issue) { stub_issue }
    let(:issue_params) { issue.marshal_dump }
    let(:board) { create(:kanban_board, :with_columns) }
    let(:column) { board.columns.first }
    let!(:issue_stat) { create(:issue_stat, board: board, column: column, number: issue.number) }
    let(:cached_issues) { nil }
    before { subject }

    it { expect(response).to have_http_status(:success) }
    it { expect(controller).to have_received(:broadcast_column).with(column) }

    context 'cache empth' do
      it { expect(Cached::UpdateIssues).not_to have_received(:call) }
    end

    context 'cache not empth' do
      let(:cached_issues) { {} }
      it do
        expect(Cached::UpdateIssues).
          to have_received(:call).
          with(
            board: board,
            objects: { issue.number => issue }
          )
      end
    end
  end
end
