describe ColumnsController do
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  before { stub_sign_in(user) }
  before { allow(controller).to receive(:broadcast_column) }

  describe '#show' do
    subject { get :show, params: { id: column.id } }
    let(:column) { board.columns.second }

    it { expect(response).to have_http_status(:success) }
  end

  describe '#new' do
    before do
      get :new, params: { board_github_full_name: board.github_full_name }
    end

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template(:new) }
  end

  describe '#create' do
    before do
      post(
        :create,
        params: {
          board_github_full_name: board.github_full_name,
          column: params
        }
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
        params: {
          board_github_full_name: board.github_full_name,
          id: column.id,
          issues: []
        }
      )
    end
    let(:column) { board.columns.first }
    before { subject }

    it { expect(response).to have_http_status(:success) }
    it { expect(response.body).to be_blank }
    # TODO Extract Broadcaster
    #it { expect(controller).to have_received(:broadcast_column).with(column) }
  end

  describe '#destroy' do
    subject do
      get :destroy, params: {
        id: column.id,
        board_github_full_name: board.github_full_name
      }
    end
    let(:column) { board.columns.last }
    let!(:issues) {}
    before { subject }

    context 'without issues' do
      it { expect(response).to have_http_status(:success) }
      it { expect(board.reload.columns).to have(1).item }
    end

    context 'without issues' do
      let!(:issues) { create :issue_stat, column: column }

      it { expect(response).to have_http_status(:success) }
      it { expect(board.reload.columns).to have(2).item }
    end
  end

  describe '#move_left' do
    subject do
      get :move_left, params: {
        id: column.id,
        board_github_full_name: board.github_full_name
      }
    end
    let(:column) { board.columns.last }

    it { expect { subject }.to change { column.reload.order }.from(2).to(1) }

    context 'response' do
      before { subject }
      it { expect(response).to redirect_to(un board_url(board)) }
    end
  end

  describe '#move_right' do
    subject do
      get :move_right, params: {
        id: column.id,
        board_github_full_name: board.github_full_name
      }
    end
    let(:column) { board.columns.first }

    it { expect { subject }.to change { column.reload.order }.from(1).to(2) }

    context 'response' do
      before { subject }
      it { expect(response).to redirect_to(un board_url(board)) }
    end
  end
end
