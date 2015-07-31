RSpec.describe LandingController, type: :controller do
  render_views

  describe '#index' do
    let(:request) { get :index }

    context 'signed_in' do
      before { stub_sign_in }
      before { request }

      it { expect(response).to redirect_to(boards_url) }
    end

    context 'not signed_in' do
      before { request }

      it { expect(response).to have_http_status(:success) }
    end
  end
end
