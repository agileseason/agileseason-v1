RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  before { stub_sign_in(user) }

  describe 'GET create' do
    before { allow_any_instance_of(GithubApi).to receive(:add_comment) }
    it 'return http success' do
      get :create, board_github_full_name: board.github_full_name, number: 1
      expect(response.body).to be_empty
    end
  end

  describe 'GET update' do
    before { allow_any_instance_of(GithubApi).to receive(:update_comment) }
    it 'return http success' do
      get :update, board_github_full_name: board.github_full_name, number: 1
      expect(response.body).to be_empty
    end
  end

  describe 'GET delete' do
    before { allow_any_instance_of(GithubApi).to receive(:delete_comment) }
    it 'return http success' do
      get :delete, board_github_full_name: board.github_full_name, number: 1
      expect(response.body).to be_empty
    end
  end
end
