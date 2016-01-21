describe ExportsController do
  before { stub_sign_in(user) }

  describe '#show' do
    let(:request) { get(:show, board_github_full_name: board.github_full_name) }
    let(:board) { create(:board, :with_columns, user: user) }
    let(:user) { create :user }
    before { request }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template(:show) }
  end
end
