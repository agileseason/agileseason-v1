describe WebhooksController do
  describe '#github' do
    before { get :github }
    it { expect(response).to have_http_status(:success) }
  end
end
