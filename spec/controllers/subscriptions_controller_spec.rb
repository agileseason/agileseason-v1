describe SubscriptionsController do
  describe '#new' do
    let(:user) { create(:user) }
    let!(:board) { create(:board, :with_columns, user: user) }
    let(:request) do
      get(:new, board_github_full_name: board.github_full_name)
    end
    before { stub_sign_in(user) }
    before { request }
  end
end
