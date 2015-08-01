RSpec.describe IssuesController, type: :controller do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  let(:column_1) { board.columns.first }
  let(:issue) { stub_issue(number: 1) }
  let(:github_api) { GithubApi.new('fake_token', user) }
  before { stub_sign_in(user) }
  before { allow(controller).to receive(:broadcast_column) }

  describe '#show' do
    let(:request) { get :show, board_github_full_name: board.github_full_name, number: 1 }
    before { allow(controller).to receive(:github_api).and_return(github_api) }
    before { allow(github_api).to receive(:issue).and_return(issue) }
    before { allow(github_api).to receive(:labels).and_return([]) }
    before { allow(github_api).to receive(:issue_comments).and_return([]) }

    context 'issue in cache' do
      before { allow(github_api).to receive(:issues).and_return([issue]) }
      before { request }

      it { expect(github_api).not_to have_received(:issue) }
      it { expect(board.reload.issue_stats.count).to eq 0 }
      it { expect((assigns :issue).issue_stat).to be_present }
    end

    context 'issue not in cache' do
      before { allow(github_api).to receive(:issues).and_return([]) }
      before { request }

      it { expect(assigns :issue).to be_present }
      it { expect((assigns :issue).number).to eq issue.number }
    end
  end

  describe '#move_to', :focus do
    let(:board) { create(:board, :with_columns, user: user) }
    let(:column_to) { board.columns.first }
    let(:request) do
      get(
        :move_to,
        board_github_full_name: board.github_full_name,
        number: 1,
        column_id: column_to.id
      )
    end
    before { allow(controller).to receive(:github_api).and_return(github_api) }
    before { allow(github_api). to receive(:move_to) }
    before { allow(github_api).to receive(:repos).and_return([]) }
    before { allow(github_api).to receive(:issues).and_return([issue]) }

    context 'not auto_assing' do
      before { request }
      it { expect(github_api).to have_received(:move_to) }
    end

    context 'auto_assign' do
      before { allow(github_api).to receive(:issue).and_return(issue) }
      before { allow(github_api).to receive(:assign).and_return(issue) }
      before { column_to.update(is_auto_assign: true) }
      before { request }

      it { expect(github_api).to have_received(:move_to) }

      context 'without assignee' do
        it { expect(github_api).to have_received(:assign) }
      end

      context 'with assignee' do
        let(:issue) { stub_issue(number: 1, assignee: {}) }
        it { expect(github_api).not_to have_received(:assign) }
      end
    end
  end

  describe '#search' do
    before { allow_any_instance_of(GithubApi).to receive(:search_issues).and_return([]) }
    it 'return http success' do
      get :search, board_github_full_name: board.github_full_name, query: 'test'
      expect(response).to render_template(partial: '_search_result')
    end
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
    let(:issue_stat) { build(:issue_stat, board: board, column: column_1) }
    let(:request) { get :archive, board_github_full_name: board.github_full_name, number: 1 }
    before { allow_any_instance_of(GithubApi).to receive(:issues).and_return([]) }
    before do
      allow_any_instance_of(GithubApi).
        to receive(:archive).and_return(BoardIssue.new(issue, issue_stat))
    end
    before { request }

    it { expect(response).to have_http_status(:success) }
    it { expect(controller).to have_received(:broadcast_column).with(issue_stat.column) }
  end

  describe '#unarchive' do
    let(:issue_stat) { create(:issue_stat, board: board, column: column_1) }
    let(:request) { get :unarchive, board_github_full_name: board.github_full_name, number: 1 }
    before { allow(IssueStatService).to receive(:unarchive!).and_return(issue_stat) }
    before { request }

    it { expect(response).to have_http_status(:success) }
    it { expect(controller).to have_received(:broadcast_column).with(issue_stat.column) }
    it { expect(IssueStatService).to have_received(:unarchive!) }
  end

  describe '#assignee' do
    let(:issue) { stub_issue(assigne: 'fake') }
    before { allow_any_instance_of(GithubApi).to receive(:assign).and_return(issue) }
    before { allow_any_instance_of(GithubApi).to receive(:issue).and_return(issue) }
    before { allow_any_instance_of(GithubApi).to receive(:issues).and_return([]) }

    it 'return http success' do
      get :assignee, board_github_full_name: board.github_full_name, number: 1, login: 'github_user'
      expect(response).to have_http_status(:success)
    end
  end

  describe '#update' do
    before do
      allow_any_instance_of(GithubApi).to receive(:update_issue).and_return(issue)
      allow_any_instance_of(GithubApi).to receive(:issues).and_return([])

      post :update, board_github_full_name: board.github_full_name,
        number: 1,
        issue: { title: 'dsgf' }
    end

    it { expect(response).to have_http_status(:success) }
  end

  describe '#due_date' do
    let(:date) { '10/11/2015 12:00' }
    let!(:issue) { create(:issue_stat, board: board, number: 1, due_date_at: nil) }
    before do
      post :due_date, board_github_full_name: board.github_full_name, number: 1, due_date: date
    end

    it { expect(response).to have_http_status(:success) }
    it { expect(response.body).to eq 'Nov 10 12:00' }
    it { expect(issue.reload.due_date_at).to eq date }
  end
end
