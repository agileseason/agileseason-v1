RSpec.describe IssuesController, type: :controller do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  before { stub_sign_in(user) }

  describe 'GET comments' do
    before { allow_any_instance_of(GithubApi).to receive(:issue_comments).and_return([]) }
    it 'return http success' do
      get :comments, board_github_full_name: board.github_full_name, number: 1
      expect(response).to render_template(partial: '_comments')
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

  describe 'GET update' do
    before { allow_any_instance_of(GithubApi).to receive(:update_issue) }
    it 'return http success' do
      get :update, board_github_full_name: board.github_full_name, number: 1
      expect(response).to redirect_to(board_url(board))
    end
  end
end
