RSpec.describe ActivitiesController, type: :controller do
  render_views

  describe 'GET index' do
    let(:user) { create(:user) }
    let!(:board) { create(:board, :with_columns, user: user) }
    let!(:issue_stat) { create(:issue_stat, :closed, board: board) }
    let!(:activity_1) { create(:archive_activity, board: board, user: user, issue_stat: issue_stat) }
    before { stub_sign_in(user) }

    before(:each) do
      create_list(
        :column_changed_activity,
        40,
        board_id: board.id,
        user_id: user.id,
        issue_stat_id: issue_stat.id)
    end

    context 'next page of activities' do
      before do
        get :index, board_github_full_name: board.github_full_name, page: 2
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template(partial: '_index') }
    end

    context 'no next page of activities' do
      before do
        get :index, board_github_full_name: board.github_full_name, page: 3
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(response.body).to eq '' }
    end
  end
end
