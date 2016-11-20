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

  describe '#close' do
    subject do
      get(
        :close,
        params: {
          board_github_full_name: board.github_full_name,
          number: 1
        }
      )
    end
    let(:issue_stat) { build(:issue_stat, board: board, column: column_1) }

    before do
      allow(IssueStats::Closer).
        to receive(:call).
        and_return(issue_stat)
    end
    before { allow(Graphs::IssueStatsWorker).to receive(:perform_async) }
    before { subject }

    it { expect(response).to have_http_status(:success) }
    it { expect(Graphs::IssueStatsWorker).to have_received(:perform_async) }
    it { expect(controller).to have_received(:broadcast_column).with(issue_stat.column) }
    it { expect(IssueStats::Closer).to have_received(:call) }
  end

  describe '#reopen' do
    subject do
      get(
        :reopen,
        params: {
          board_github_full_name: board.github_full_name,
          number: 1
        }
      )
    end
    let(:issue_stat) { build(:issue_stat, board: board, column: column_1) }

    before do
      allow_any_instance_of(IssueStats::Reopener).
        to receive(:call).
        and_return(issue_stat)
    end
    before { allow(Graphs::IssueStatsWorker).to receive(:perform_async) }

    context 'request' do
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it { expect(Graphs::IssueStatsWorker).to have_received(:perform_async) }
      it { expect(controller).to have_received(:broadcast_column).with(issue_stat.column) }
    end

    context 'behavior' do
      after { subject }
      it { expect_any_instance_of(IssueStats::Reopener).to receive(:call) }
    end
  end

  describe '#archive' do
    subject do
      get(:archive, params: {
        board_github_full_name: board.github_full_name,
        number: 1
      })
    end
    let(:issue_stat) { build(:issue_stat, board: board, column: column_1) }
    before do
      allow_any_instance_of(IssueStats::Archiver).
        to receive(:call).and_return(issue_stat)
    end

    context 'request' do
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it { expect(controller).to have_received(:broadcast_column).with(issue_stat.column) }
    end

    context 'behavior' do
      after { subject }
      it { expect_any_instance_of(IssueStats::Archiver).to receive(:call) }
    end
  end

  describe '#unarchive' do
    subject do
      get(:unarchive, params: {
        board_github_full_name: board.github_full_name, number: 1
      })
    end
    let(:issue_stat) { create(:issue_stat, board: board, column: column_1) }
    before do
      allow_any_instance_of(IssueStats::Unarchiver).
        to receive(:call).and_return(issue_stat)
    end

    context 'request' do
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it do
        expect(controller).
          to have_received(:broadcast_column).
          with(issue_stat.column, true)
      end
    end

    context 'behavior' do
      after { subject }
      it { expect_any_instance_of(IssueStats::Unarchiver).to receive(:call) }
    end
  end

  describe '#assignee' do
    subject do
      get(:assignee, params: {
        board_github_full_name: board.github_full_name,
        number: 1,
        login: 'github_user',
        format: :json
      })
    end
    let(:issue) { stub_issue(assigne: 'fake') }
    before { allow_any_instance_of(BoardBag).to receive(:issue).and_return(issue) }

    context 'response' do
      before do
        allow_any_instance_of(IssueStats::Assigner).
          to receive(:call).
          and_return(issue)
      end
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template(partial: '_issue_miniature') }
    end

    context 'behavior' do
      after { subject }
      it { expect_any_instance_of(IssueStats::Assigner).to receive(:call) }
    end
  end

  describe '#due_date' do
    let(:date) { '10/11/2015 12:00' }
    let!(:issue) { create(:issue_stat, board: board, number: 1, due_date_at: nil) }
    before do
      post(:due_date, params: {
        board_github_full_name: board.github_full_name, number: 1, due_date: date
      })
    end

    it { expect(response).to have_http_status(:success) }
    it { expect(response.body).to eq 'Nov 10 12:00' }
    it { expect(issue.reload.due_date_at).to eq date }
  end

  describe '#toggle_ready' do
    let(:issue_stat) { create :issue_stat, board: board, is_ready: is_ready }
    before do
      post(:toggle_ready, params: {
        board_github_full_name: board.github_full_name,
        number: issue_stat.number
      })
    end

    context 'true' do
      let(:is_ready) { true }

      it { expect(response).to have_http_status(:success) }
      it { expect(issue_stat.reload.is_ready).to eq false }
      it { expect(controller).to have_received(:broadcast_column).with(issue_stat.column) }
    end

    context 'flase' do
      let(:is_ready) { false }

      it { expect(response).to have_http_status(:success) }
      it { expect(issue_stat.reload.is_ready).to eq true }
      it { expect(controller).to have_received(:broadcast_column).with(issue_stat.column) }
    end
  end
end
