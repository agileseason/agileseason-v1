RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  before { stub_sign_in(user) }

  describe 'GET index' do
    before { allow_any_instance_of(GithubApi).to receive(:issue_comments).and_return([]) }
    it 'return http success' do
      get :index, board_github_full_name: board.github_full_name, number: 1
      expect(response).to render_template(partial: '_index')
    end
  end

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

  describe '#delete' do
    subject { delete :delete, board_github_full_name: board.github_full_name, number: 1 }

    context 'check responce' do
      before { allow_any_instance_of(GithubApi).to receive(:delete_comment) }
      before { subject }
      it { expect(response).to have_http_status(:success) }
      it { expect(response.body).to be_empty }
    end

    context 'call delete_comment' do
      after { subject }
      it { expect_any_instance_of(GithubApi).to receive(:delete_comment).once }
    end
  end
end
