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
      before { xhr :get, :index }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template('boards/_board_list') }
    end

    context 'request is not xhr' do
      before { get :index }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template(:index) }
    end
  end

  describe '#new' do
    let(:repo) { OpenStruct.new(id: 1, name: 'foo', full_name: 'bar/foo') }
    before do
      allow_any_instance_of(GithubApi).
        to receive(:cached_repos).and_return([repo])
    end
    before { stub_sign_in }

    it 'returns http success' do
      get :new, github_id: repo.id
      expect(response).to have_http_status(:success)
    end
  end

  describe '#show' do
    let(:request) { get(:show, github_full_name: board.github_full_name) }
    let(:user) { create(:user) }
    let(:issue) { stub_issue(labels: [label_1]) }
    let(:label_1) { OpenStruct.new(name: 'techdebt', color: '000') }
    let(:label_2) { OpenStruct.new(name: 'bug', color: '000') }
    before { allow_any_instance_of(GithubApi).to receive(:issues).and_return([issue]) }
    before { allow_any_instance_of(GithubApi).to receive(:labels).and_return([label_1, label_2]) }
    before { allow_any_instance_of(GithubApi).to receive(:collaborators).and_return([]) }
    before do
      allow_any_instance_of(BoardBag).
        to receive(:private_repo?).
        and_return(is_private)
    end
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

  describe '#create' do
    subject { Board.where(user_id: user.id).first }
    let(:user) { create(:user) }
    before do
      allow_any_instance_of(User).
        to receive(:repo_admin?).and_return(true)
      allow_any_instance_of(GithubApi).
        to receive(:cached_repos).and_return([])
    end
    before { stub_sign_in(user) }
    before do
      post(
        :create,
        board: {
          name: 'test-1',
          type: 'Boards::KanbanBoard',
          github_id: '123',
          github_name: 'test-1',
          github_full_name: 'test/test-1',
          column: { name: column_names }
        }
      )
    end

    context 'success' do
      let(:column_names) { ['c1', 'c2', '', nil] }

      its(:name) { is_expected.to eq 'test-1' }
      it { expect(subject.columns.map(&:name)).to eq ['c1', 'c2'] }
    end

    context 'to few columns' do
      let(:column_names) { ['c1'] }
      it { is_expected.to be_nil }
    end
  end

  describe 'DELETE destroy' do
    let(:user) { create(:user) }
    let(:repo) { OpenStruct.new(id: board.github_id) }
    let(:request) { delete(:destroy, github_full_name: board.github_full_name) }
    before do
      allow_any_instance_of(GithubApi).
        to receive(:cached_repos).and_return([repo])
    end
    before { stub_sign_in(user) }

    context 'owner' do
      before { request }
      let(:reader?) { false }
      let(:board) { create(:board, :with_columns, user: user) }
      it { expect(response).to have_http_status(:redirect) }
      it { expect(response).to redirect_to(boards_url) }
      it { expect(Board.where(id: board.id).count).to be_zero }
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
