RSpec.describe IssuesController, type: :controller do
  let(:user) { create(:user) }
  let(:board) { create(:kanban_board, :with_columns, user: user) }
  let(:column_1) { board.columns.first }
  let(:issue) { stub_issue(number: 1) }
  let(:github_api) { GithubApi.new('fake_token', user) }
  before { stub_sign_in(user) }
  before { allow(controller).to receive(:broadcast_column) }
  before { allow(controller).to receive(:github_api).and_return(github_api) }

  describe '#show' do
    let(:request) { get :show, board_github_full_name: board.github_full_name, number: 1 }
    before { allow(github_api).to receive(:issue_comments).and_return([]) }
    before { allow_any_instance_of(BoardBag).to receive(:issue).and_return(issue) }
    before { request }

    it { expect(assigns :issue).to be_present }
    it { expect((assigns :issue).number).to eq issue.number }
  end

  describe '#create' do
    let(:request) do
      post(
        :create,
        board_github_full_name: board.github_full_name,
        number: issue.number,
        issue: params
      )
    end
    before { allow(github_api).to receive(:create_issue).and_return(issue) }
    before { allow(github_api).to receive(:issues).and_return([]) }
    before { allow(controller).to receive(:ui_event) }

    context 'response' do
      let(:params) { { title: 'test edit title' } }
      before { request }

      it { expect(response).to have_http_status(:success) }
      it { expect(github_api).to have_received(:create_issue) }
      it { expect(controller).to have_received(:ui_event).with(:issue_create) }
    end

    context 'behavior' do
      before { allow(Issue).to receive(:new).and_return(Issue.new) }
      before { request }

      context 'with labels' do
        let(:params) do
          { title: 'test edit title', labels: ['label-1', 'label-2'] }
        end
        it { expect(Issue).to have_received(:new).with(params) }
      end

      context 'without labels' do
        let(:params) { { title: 'test edit title' } }
        it { expect(Issue).to have_received(:new).with(params) }
      end
    end
  end

  describe '#update' do
    let(:request) do
      patch(
        :update,
        board_github_full_name: board.github_full_name,
        number: issue.number,
        issue: params
      )
    end
    let(:params) { { title: 'test edit title' } }
    before { allow(github_api).to receive(:issues).and_return([]) }
    before { allow(github_api).to receive(:update_issue).and_return(issue) }

    context 'response' do
      before { request }

      it { expect(response).to have_http_status(:success) }
      it do
        expect(github_api).
          to have_received(:update_issue).
          with(board, issue.number, params)
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

  describe '#update_labels' do
    let(:request) do
      patch(
        :update_labels,
        board_github_full_name: board.github_full_name,
        number: issue.number,
        issue: params
      )
    end
    let(:params) { { labels: ['label-1', 'label-2'] } }
    before { allow(github_api).to receive(:issues).and_return([]) }
    before { allow(github_api).to receive(:update_issue).and_return(issue) }

    context 'direct' do
      before { request }

      it { expect(response).to have_http_status(:success) }
      it do
        expect(github_api).
          to have_received(:update_issue).
          with(board, issue.number, params)
      end
    end

    context 'cache' do
      after { request }

      it do
        expect_any_instance_of(BoardBag).
          to receive(:update_cache).with(issue)
      end
    end
  end

  describe '#move_to' do
    let(:board) { create(:board, :with_columns, user: user) }
    let(:column_to) { board.columns.first }
    let(:issue_stat) { create(:issue_stat, number: number, board: board, column: column_to) }
    let(:number) { 1 }
    let(:request) do
      get(
        :move_to,
        board_github_full_name: board.github_full_name,
        number: number,
        column_id: column_to.id
      )
    end
    before { allow(controller).to receive(:github_api).and_return(github_api) }
    before { allow(github_api).to receive(:issues).and_return([issue]) }
    before { allow(github_api).to receive(:issue).and_return(issue) }
    before do
      allow_any_instance_of(IssueStats::Mover).
        to receive(:call)
    end
    before do
      allow_any_instance_of(IssueStats::Finder).
        to receive(:call).
        and_return(issue_stat)
    end
    before do
      allow_any_instance_of(IssueStats::AutoAssigner).
        to receive(:call)
    end

    context 'responce' do
      before { request }
      it { expect(response).to have_http_status(:success) }
    end

    context 'behavior' do
      after { request }
      it { expect_any_instance_of(IssueStats::Mover).to receive(:call) }
      it { expect_any_instance_of(IssueStats::AutoAssigner).to receive(:call) }
      it { expect_any_instance_of(IssueStats::Sorter).to receive(:call) }
      it { expect_any_instance_of(IssueStats::Unready).to receive(:call) }
    end
  end

  describe '#search' do
    let(:request) do
      get :search, board_github_full_name: board.github_full_name, query: 'test'
    end
    before { allow_any_instance_of(GithubApi).to receive(:search_issues).and_return([]) }
    before { allow(controller).to receive(:ui_event) }
    before { request }

    it { expect(response).to render_template(partial: '_search_result') }
    it { expect(controller).to have_received(:ui_event).with(:issue_search) }
  end

  describe '#close' do
    let(:request) { get :close, board_github_full_name: board.github_full_name, number: 1 }
    let(:issue_stat) { build(:issue_stat, board: board, column: column_1) }

    before { allow_any_instance_of(GithubApi).to receive(:issues).and_return([]) }
    before do
      allow_any_instance_of(GithubApi).
        to receive(:close).and_return(BoardIssue.new(issue, issue_stat))
    end
    before { allow(Graphs::IssueStatsWorker).to receive(:perform_async) }
    before { allow(Graphs::CumulativeWorker).to receive(:perform_async) }
    before { request }

    it { expect(response).to have_http_status(:success) }
    it { expect(Graphs::IssueStatsWorker).to have_received(:perform_async) }
    it { expect(Graphs::CumulativeWorker).to have_received(:perform_async) }
    it { expect(controller).to have_received(:broadcast_column).with(issue_stat.column) }
  end

  describe '#reopen' do
    let(:request) do
      get :reopen, board_github_full_name: board.github_full_name, number: 1
    end
    let(:board_issue) { BoardIssue.new(stub_issue(number: 1), issue_stat) }
    let(:issue_stat) do
      create(:issue_stat, :closed, board: board, column: column_1, number: 1)
    end

    before { allow(Graphs::IssueStatsWorker).to receive(:perform_async) }
    before do
      allow_any_instance_of(GithubApi).
        to receive(:reopen).and_return(board_issue)
    end
    before { allow_any_instance_of(BoardBag).to receive(:update_cache) }
    before { request }

    it { expect(response).to have_http_status(:success) }
    it { expect(controller).to have_received(:broadcast_column).with(issue_stat.column) }
    it { expect(Graphs::IssueStatsWorker).to have_received(:perform_async) }
  end

  describe '#archive' do
    subject { get :archive, board_github_full_name: board.github_full_name, number: 1 }
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
    subject { get :unarchive, board_github_full_name: board.github_full_name, number: 1 }
    let(:issue_stat) { create(:issue_stat, board: board, column: column_1) }
    before do
      allow_any_instance_of(IssueStats::Unarchiver).
        to receive(:call).and_return(issue_stat)
    end

    context 'request' do
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it { expect(controller).to have_received(:broadcast_column).with(issue_stat.column) }
    end

    context 'behavior' do
      after { subject }
      it { expect_any_instance_of(IssueStats::Unarchiver).to receive(:call) }
    end
  end

  describe '#assignee' do
    let(:issue) { stub_issue(assigne: 'fake') }
    before { allow_any_instance_of(GithubApi).to receive(:assign).and_return(issue) }
    before { allow_any_instance_of(GithubApi).to receive(:issue).and_return(issue) }
    before { allow_any_instance_of(GithubApi).to receive(:issues).and_return([]) }

    it 'return http success' do
      get :assignee, board_github_full_name: board.github_full_name,
        number: 1, login: 'github_user'
      expect(response).to have_http_status(:success)
    end
  end

  describe '#due_date' do
    let(:date) { '10/11/2015 12:00' }
    let!(:issue) { create(:issue_stat, board: board, number: 1, due_date_at: nil) }
    before do
      post :due_date, board_github_full_name: board.github_full_name,
        number: 1, due_date: date
    end

    it { expect(response).to have_http_status(:success) }
    it { expect(response.body).to eq 'Nov 10 12:00' }
    it { expect(issue.reload.due_date_at).to eq date }
  end

  describe '#ready' do
    context 'true' do
      let!(:issue_stat) { create :issue_stat, board: board, number: 1 }

      before do
        patch :ready, board_github_full_name: board.github_full_name,
          number: 1, issue_stat: { is_ready: 'true' }
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(issue_stat.reload.is_ready).to eq true }
    end

    context 'flase' do
      let!(:issue_stat) { create :issue_stat, board: board, number: 1, is_ready: true }

      before do
        patch :ready, board_github_full_name: board.github_full_name,
          number: 1, issue_stat: { is_ready: 'false' }
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(issue_stat.reload.is_ready).to eq false }
    end
  end
end
