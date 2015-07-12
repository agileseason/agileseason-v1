describe ColumnsController, type: :controller do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  before { stub_sign_in(user) }
  before { allow(controller).to receive(:broadcast_column) }

  describe '#new' do
    let(:request) { get :new, board_github_full_name: board.github_full_name }
    before { request }
    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template(:new) }
  end

  describe '#update' do
    let(:request) do
      patch :update, board_github_full_name: board.github_full_name, id: column.id, issues: []
    end
    let(:column) { board.columns.first }
    before { request }

    it { expect(response).to have_http_status(:success) }
    it { expect(response.body).to be_blank }
    it { expect(controller).to have_received(:broadcast_column).with(column) }
  end
end
