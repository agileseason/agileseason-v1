describe SubscriptionsController do
  let(:user) { create(:user) }
  before { stub_sign_in(user) }

  describe '#new' do
    let(:board) { create(:board, :with_columns, user: user) }
    before do
      get(:new, params: {
        board_github_full_name: board.github_full_name
      })
    end

    it { expect(response).to have_http_status(:success) }
  end

  describe '#early_access' do
    let(:board) { create(:kanban_board, :with_columns, user: user) }
    let(:subscription) { build(:subscription) }
    before do
      allow(Subscriber).
        to receive(:early_access).
        and_return(subscription)
    end
    before do
      get(:early_access, params: {
        board_github_full_name: board.github_full_name
      })
    end

    it { expect(response).to redirect_to(un(board_url(board))) }
    it do
      expect(Subscriber).to have_received(:early_access).
        with(board, user)
    end
  end
end
