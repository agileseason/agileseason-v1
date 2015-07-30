RSpec.describe LandingController, type: :controller do
  render_views

  describe '#index' do
    let(:request) { get :index }
    before { allow(controller).to receive(:ui_event) }

    context 'signed_in' do
      before { stub_sign_in }
      before { request }

      it { expect(response).to redirect_to(boards_url) }
      it { expect(controller).not_to have_received(:ui_event) }
    end

    context 'not signed_in' do
      before { request }

      it { expect(response).to have_http_status(:success) }
      it { expect(controller).to have_received(:ui_event) }
    end
  end
end
