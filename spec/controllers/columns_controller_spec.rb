describe ColumnsController, type: :controller do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  before { stub_sign_in(user) }
  before { allow(controller).to receive(:broadcast_column) }

  describe '#show' do
    subject { get :show, id: column.id }
    let(:column) { board.columns.second }

    it { expect(response).to have_http_status(:success) }
  end

  describe '#new' do
    before { get :new, board_github_full_name: board.github_full_name }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template(:new) }
  end

  describe '#create', :focus do
    before do
      post(
        :create,
        board_github_full_name: board.github_full_name,
        column: params
      )
    end

    context 'valid params' do
      let(:params) { { name: 'new-column' } }

      it { expect(response).to redirect_to(un board_settings_url(board)) }
      it { expect(board.reload.columns).to have(3).items }
      it { expect(board.reload.columns.last.name).to eq 'new-column' }
    end

    context 'invalid params' do
      let(:params) { { name: ' ' } }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template(:new) }
      it { expect(board.reload.columns).to have(2).items }
    end
  end

  describe '#update' do
    subject do
      patch(
        :update,
        board_github_full_name: board.github_full_name,
        id: column.id,
        issues: []
      )
    end
    let(:column) { board.columns.first }
    before { subject }

    it { expect(response).to have_http_status(:success) }
    it { expect(response.body).to be_blank }
    it { expect(controller).to have_received(:broadcast_column).with(column) }
  end

  describe '#destroy' do
    subject { get :destroy, id: column.id }
    let(:column) { board.columns.last }
    before { subject }

    context 'without issues' do
      it { expect(response).to have_http_status(:success) }
      it { expect(board.reload.columns).to have(1).item }
    end
  end
end
