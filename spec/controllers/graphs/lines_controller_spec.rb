describe Graphs::LinesController do
  describe '#index' do
    let(:user) { create(:user) }
    let(:board) { create(:board, :with_columns, user: user) }

    before { stub_sign_in(user) }
    before do
      get(:index, params: {
        board_github_full_name: board.github_full_name
      })
    end

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template(:index) }
  end
end
