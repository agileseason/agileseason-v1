describe Graphs::AgeController do
  let(:user) { create(:user) }
  let(:board) { create(:kanban_board, :with_columns, user: user) }
  before { stub_sign_in(user) }
  before do
    allow_any_instance_of(BoardBag).
      to receive(:board_issues).and_return([])
  end

  describe '#index' do
    subject { get :index, board_github_full_name: board.github_full_name }
    before { subject }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template(:index) }
  end
end
