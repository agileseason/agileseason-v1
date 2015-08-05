describe SubscriptionsController do
  let(:user) { create(:user) }
  before { stub_sign_in(user) }

  describe '#new' do
    let(:board) { create(:board, :with_columns, user: user) }
    let(:request) do
      get(:new, board_github_full_name: board.github_full_name)
    end
    before { request }

    it { expect(response).to have_http_status(:success) }
  end

  describe '#early_access' do
    let(:request) do
      get(:early_access, board_github_full_name: board.github_full_name)
    end
    let(:board) { create(:kanban_board, :with_columns, user: user) }
    before { allow(Subscriber).to receive(:early_access) }
    before { request }

    it { expect(response).to redirect_to(board) }
    it { expect(Subscriber).to have_received(:early_access).with(board, user) }
  end
end
