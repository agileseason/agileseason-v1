RSpec.describe ActivitiesController, type: :controller do
  render_views

  describe 'GET index' do
    let(:user) { create(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    let!(:issue_stat) { create(:issue_stat, :closed, board: board) }
    let!(:activity_1) { create(:archive_activity, board: board, user: user, issue_stat: issue_stat) }
    let!(:activity_2) { create(:column_changed_activity, board: board, user: user, issue_stat: issue_stat) }
    before { stub_sign_in(user) }

    it 'returns http success' do
      get :index, board_github_name: board.github_name
      expect(response).to have_http_status(:success)
    end
  end
end
