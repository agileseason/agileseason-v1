describe IssuesController do
  let(:number) { 1 }
  let(:user) { create(:user) }
  let(:board) { create(:kanban_board, :with_columns, user: user) }
  let(:column_1) { board.columns.first }
  let(:issue) { stub_issue(number: number) }
  let(:github_api) { GithubApi.new('fake_token', user) }
  before { stub_sign_in(user) }
  before { allow(controller).to receive(:broadcast_column) }
  before { allow(controller).to receive(:github_api).and_return(github_api) }

  describe '#show' do
    before { allow(github_api).to receive(:issue_comments).and_return([]) }
    before { allow_any_instance_of(BoardBag).to receive(:issue).and_return(issue) }
    before { request }

    context 'html' do
      let(:request) do
        get(:show, params: {
          board_github_full_name: board.github_full_name, number: number
        })
      end

      it do
        expect(response).to redirect_to(un(board_url(board, number: number)))
      end
    end

    context 'json' do
      let(:request) do
        get(
          :show,
          params: {
            board_github_full_name: board.github_full_name,
            number: number,
            format: :json
          }
        )
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(assigns :issue).to be_present }
      it { expect((assigns :issue).number).to eq issue.number }
    end
  end

  describe '#create' do
    subject do
      post(
        :create,
        params: {
          board_github_full_name: board.github_full_name,
          number: issue.number,
          issue: params
        }
      )
    end
    let(:params) { { title: 'test edit title' } }
    let(:issue_stat) do
      create(:issue_stat, number: issue.number, board: board, column: column_1)
    end
    let(:creator) { double(call: created_issue) }
    let(:created_issue) { BoardIssue.new(issue, issue_stat) }
    before { allow(IssueStats::Creator).to receive(:new).and_return(creator) }
    before { allow(controller).to receive(:ui_event) }

    context 'response' do
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template(partial: '_issue_miniature') }
      it { expect(controller).to have_received(:ui_event).with(:issue_create) }
      it { expect(creator).to have_received(:call) }
      it { expect(controller).to have_received(:broadcast_column) }
    end
  end

  describe '#update' do
    let(:request) do
      patch(
        :update,
        params: {
          board_github_full_name: board.github_full_name,
          number: issue.number,
          issue: issue_params
        }
      )
    end
    let(:issue_params) { { title: 'test edit title' } }
    before { allow(Cached::Issues).to receive(:call).and_return([]) }
    before { allow(github_api).to receive(:update_issue).and_return(issue) }

    context 'response' do
      before { request }

      it { expect(response).to have_http_status(:success) }
      it do
        expect(github_api).
          to have_received(:update_issue).
          with(board, issue.number, issue_params)
      end
    end

    context 'behavior' do
      after { request }

      it do
        expect_any_instance_of(BoardBag).
          to receive(:update_cache).with(issue)
      end
    end
  end
end
