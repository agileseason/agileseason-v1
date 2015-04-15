RSpec.describe LandingController, type: :controller do
  render_views

  describe 'GET index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end
