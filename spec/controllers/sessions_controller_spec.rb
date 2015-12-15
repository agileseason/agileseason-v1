describe SessionsController do
  describe '#create' do
    subject { post :create }
    let(:return_url) {}
    before { allow_any_instance_of(MixpanelTracker).to receive(:link_user) }
    before { allow(controller).to receive(:github_username_auth).and_return 'user-name' }
    before { allow(controller).to receive(:github_email_address_auth).and_return 'user@mail.com' }
    before { allow(controller).to receive(:github_token_auth).and_return 'test-token' }
    before { allow(controller).to receive(:ui_event) }
    before do
      cookies[:source] = 'test-source'
      cookies[:medium] = 'test-medium'
      cookies[:campaign] = 'tset-campaign'
    end
    before { session[:return_url] = return_url }
    before { subject }

    context 'without return url' do
      it { expect(response).to redirect_to(boards_url) }
    end

    context 'with return url' do
      let(:return_url) { '/demo_board' }
      it { expect(response).to redirect_to(return_url) }
      it { expect(session[:return_url]).to be_nil }
    end
  end

  describe '#destroy' do
    subject { get :destroy }
    before { session[:github_token] = 'fake_token' }
    before { subject }

    it { expect(response).to redirect_to(root_url) }
    it { expect(session[:github_token]).to be_nil }
  end
end
