describe BoardsController, type: :controller do
  render_views

  let(:s3) { OpenStruct.new(url: 's3.foo', fields: []) }
  before { allow(S3Api).to receive(:direct_post).and_return(s3) }
  before do
    allow_any_instance_of(GithubApi).
      to receive(:cached_repos).and_return([])
  end

  describe '#index' do
    before { stub_sign_in }

    context 'request is xhr' do
      before { get :index, xhr: true }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template('boards/_board_list') }
    end

    context 'request is not xhr' do
      before { get :index }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template(:index) }
    end
  end

  describe '#show' do
    let(:request) do
      get(:show, params: { github_full_name: board.github_full_name })
    end
    let(:user) { create(:user) }
    let(:issue) { stub_issue(labels: [label_1]) }
    let(:label_1) { OpenStruct.new(name: 'techdebt', color: '000') }
    let(:label_2) { OpenStruct.new(name: 'bug', color: '000') }
    let(:labels) { [label_1, label_2] }
    before do
      allow_any_instance_of(BoardBag).
        to receive(:private_repo?).
        and_return(is_private)
    end
    before { allow(Cached::Issues).to receive(:call).and_return(issue.number => issue) }
    before { allow(Cached::Labels).to receive(:call).and_return(labels) }
    before { stub_sign_in(user) }
    before { request }

    context 'private subscribed board' do
      let(:board) { create(:board, :with_columns, :subscribed, user: user) }
      let(:is_private) { true }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template(:show) }
    end

    context 'private not subscribed board' do
      let(:board) { create(:board, :with_columns, user: user) }
      let(:is_private) { true }

      it do
        expect(response).
          to redirect_to(un(new_board_subscriptions_url(board)))
      end
    end

    context 'public not subscribed board' do
      let(:board) { create(:board, :with_columns, user: user) }
      let(:is_private) { false }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template(:show) }
    end
  end

  describe '#new' do
    subject { get :new, params: { github_id: repo.id } }
    let(:repo) do
      OpenStruct.new(id: 1, name: 'foo', full_name: 'bar/foo')
    end
    before do
      allow_any_instance_of(GithubApi).
        to receive(:cached_repos).and_return([repo])
    end
    before { allow(controller).to receive(:ui_event) }
    before { stub_sign_in }
    before { subject }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template('_new') }
    it do
      expect(controller).to have_received(:ui_event).
        with(:board_new, step: 'setup board')
    end
  end


  describe '#create' do
    subject { Board.where(user_id: user.id).first }
    let(:user) { create(:user) }
    let(:board_name) { 'test-1' }
    let(:column_names) { ['c1', 'c2', '', nil] }
    before do
      allow_any_instance_of(User).
        to receive(:repo_admin?).and_return(true)
    end
    before { allow(Cached::Issues).to receive(:call).and_return({}) }
    before { allow(Boards::Create).to receive(:call).and_return(board) }
    before { allow(controller).to receive(:ui_event) }
    before { stub_sign_in(user) }
    before do
      post(
        :create,
        params: {
          board: {
            name: board_name,
            type: 'Boards::KanbanBoard',
            github_id: '123',
            github_name: 'test-1',
            github_full_name: 'test/test-1',
            is_private_repo: false,
            column: { name: column_names }
          }
        }
      )
    end

    context 'success' do
      let(:board) { build_stubbed(:board) }
      it { expect(controller).to have_received(:ui_event).with(:board_create) }
      it { expect(response).to redirect_to un(board_url(board)) }
    end

    context 'invalid' do
      let(:board) { build(:board) }
      it { expect(controller).not_to have_received(:ui_event).with(:board_create) }
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template(:new) }
    end
  end

  describe '#destroy' do
    let(:user) { create(:user) }
    let(:repo) { OpenStruct.new(id: board.github_id) }
    let(:request) do
      delete(:destroy, params: { github_full_name: board.github_full_name })
    end
    before do
      allow_any_instance_of(GithubApi).
        to receive(:cached_repos).and_return([repo])
    end
    before do
      allow_any_instance_of(GithubApi).
        to receive(:remove_issue_hook)
    end
    before { stub_sign_in(user) }

    context 'owner' do
      let(:reader?) { false }
      let(:board) { create(:kanban_board, :with_columns, user: user) }

      context 'response' do
        before { request }

        it { expect(response).to have_http_status(:redirect) }
        it { expect(response).to redirect_to(boards_url) }
        it { expect(Board.where(id: board.id).count).to be_zero }
      end

      context 'behaviour' do
        after { request }
        it do
          expect_any_instance_of(GithubApi).
            to receive(:remove_issue_hook).with(board)
        end
      end
    end

    context 'not owner but reader' do
      let(:board) { create(:board, :with_columns) }
      it { expect { request }.to raise_error(CanCan::AccessDenied) }
    end

    context 'not owner and not reader' do
      let(:board) { create(:board, :with_columns) }
      it { expect { request }.to raise_error(CanCan::AccessDenied) }
    end

    context 'not owner and not reader and public board' do
      let(:board) { create(:board, :with_columns, settings: { is_public: true }) }
      it { expect { request }.to raise_error(CanCan::AccessDenied) }
    end
  end
end
