RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  before { stub_sign_in(user) }

  describe 'create' do
    before { allow_any_instance_of(GithubApi).to receive(:add_comment) }
    it 'return http success' do
      get :create, board_github_name: board.github_name, number: 1
      expect(response.body).to be_empty
    end
  end

  describe '#update' do
    before { allow_any_instance_of(GithubApi).to receive(:update_comment) }
    it 'return http success' do
      get :update, board_github_name: board.github_name, number: 1
      expect(response.body).to be_empty
    end
  end
end
