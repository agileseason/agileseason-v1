describe SessionsController do
  describe '#sign_out' do
    let(:request) { get :destroy }
    before { request }

    it { expect(response).to redirect_to(root_url) }
  end
end
