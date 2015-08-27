describe RoadmapsController do
  describe '#show' do
    let(:board) { create(:board, :with_columns, user: user) }
    let(:user) { create(:user) }
    before { stub_sign_in(user) }

    it 'returns http success' do
      get :show, board_github_full_name: board.github_full_name
      expect(response).to have_http_status(:success)
    end
  end
end
