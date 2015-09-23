describe WebhooksController do
  before { allow(controller).to receive(:broadcast_column) }
  before { allow(controller).to receive(:trusted_request?).and_return(true) }

  describe '#github' do
    subject { get :github, params }
    let(:params) { { repository: repo, issue: issue_params } }
    let(:repo) { { full_name: board.github_full_name } }
    let(:issue) { stub_issue }
    let(:issue_params) { issue.marshal_dump }
    let(:board) { create(:board, :with_columns) }
    let(:column) { board.columns.first }
    let!(:issue_stat) { create(:issue_stat, board: board, column: column, number: issue.number) }
    before { subject }

    it { expect(response).to have_http_status(:success) }
    it { expect(controller).to have_received(:broadcast_column).with(column) }
  end
end
