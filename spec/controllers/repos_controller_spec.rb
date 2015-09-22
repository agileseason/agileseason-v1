describe ReposController do
  describe '#index' do
    let(:github_api) { double(repos: [stub_repo]) }
    before do
      allow_any_instance_of(User).
        to receive(:github_api).
        and_return(github_api)
    end
    before { allow(controller).to receive(:ui_event) }
    before { stub_sign_in }
    before { get :index }

    it { expect(response).to have_http_status(:success) }
    it do
      expect(controller).
        to have_received(:ui_event).
        with(:board_new, { step: 'choose repository' })
    end
  end
end
