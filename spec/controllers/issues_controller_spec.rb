RSpec.describe IssuesController, type: :controller do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  before { stub_sign_in(user) }

  describe 'GET search' do
    before { allow_any_instance_of(GithubApi).to receive(:search_issues).and_return([]) }
    it 'return http success' do
      get :search, board_github_full_name: board.github_full_name, query: 'test'
      expect(response).to render_template(partial: '_search_result')
    end
  end

  describe 'GET close' do
    before { allow_any_instance_of(GithubApi).to receive(:close) }
    it 'return http success' do
      get :close, board_github_full_name: board.github_full_name, number: 1
      expect(response).to redirect_to(board_url(board))
    end
  end

  describe 'GET archive' do
    before { allow_any_instance_of(GithubApi).to receive(:archive) }
    it 'return http success' do
      get :archive, board_github_full_name: board.github_full_name, number: 1
      expect(response).to redirect_to(board_url(board))
    end
  end

  describe 'GET assignee' do
    let(:issue) { OpenStruct.new(number: 1, assigne: 'fake') }
    before { allow_any_instance_of(GithubApi).to receive(:assign).and_return(issue) }
    before { allow_any_instance_of(GithubApi).to receive(:issue).and_return(issue) }
    it 'return http success' do
      get :assignee, board_github_full_name: board.github_full_name, number: 1, login: 'github_user'
      expect(response).to have_http_status(:success)
    end
  end

  describe '#update' do
    before { allow_any_instance_of(GithubApi).to receive(:update_issue) }
    before { post :update, board_github_full_name: board.github_full_name, number: 1 }

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
