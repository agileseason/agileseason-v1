describe Graphs::ForecastsController do
  describe '#index' do
    subject { get :index, board_github_full_name: board.github_full_name }
    let(:user) { create(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    before { stub_sign_in(user) }
    before { subject }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template(:index) }
  end
end
