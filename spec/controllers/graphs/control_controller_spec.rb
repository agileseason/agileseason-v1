RSpec.describe Graphs::ControlController, type: :controller do
  describe 'GET index' do
    let(:user) { create(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    it 'returns http success' do
      stub_sign_in(user)
      get :index, board_github_name: board.github_name
      expect(response).to have_http_status(:success)
    end
  end
end
