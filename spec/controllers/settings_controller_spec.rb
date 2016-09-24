describe SettingsController do
  render_views
  before do
    allow_any_instance_of(GithubApi).
      to receive(:repos).and_return([])
  end

  describe '#show' do
    let(:user) { create(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    before { stub_sign_in(user) }
    before do
      get(:show, params: {
        board_github_full_name: board.github_full_name
      })
    end

    it { expect(response).to have_http_status(:success) }
  end

  describe '#update' do
    let(:user) { create(:user) }
    let(:board) { create(:kanban_board, :with_columns, user: user) }
    before { stub_sign_in(user) }
    before do
      get(:update, params: {
        board_github_full_name: board.github_full_name,
        kanban_settings: { foo: :bar }
      })
    end

    it { expect(response).to have_http_status(:success) }
  end

  describe '#rename' do
    let(:user) { create(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    before { stub_sign_in(user) }

    context 'success' do
      before do
        get(:rename, params: {
          board_github_full_name: board.github_full_name,
          board: { name: board.name + '1' }
        })
      end

      it { expect(response).to have_http_status(:redirect) }
      it do
        expect(response).
          to redirect_to(CGI::unescape(board_settings_url(board)))
      end
    end

    context 'fail' do
      before do
        get(
          :rename, params: {
          board_github_full_name: board.github_full_name,
          board: { name: '' }
        })
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template(:show) }
    end
  end
end
