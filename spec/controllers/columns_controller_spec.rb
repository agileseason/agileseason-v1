describe ColumnsController, type: :controller do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  before { stub_sign_in(user) }

  describe 'GET new' do
    it 'return http success' do
      get :new, board_github_full_name: board.github_full_name
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end
end
