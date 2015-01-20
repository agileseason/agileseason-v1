describe SettingsController, type: :controller do
  render_views

  describe 'GET show' do
    let(:user) { create(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    before { stub_sign_in(user) }

    it 'returns http success' do
      get :show, board_github_name: board.github_name
      expect(response).to have_http_status(:success)
    end
  end
end
