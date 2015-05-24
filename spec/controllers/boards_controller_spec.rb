describe BoardsController, type: :controller do
  render_views

  let(:s3) { OpenStruct.new(url: 's3.foo', fields: []) }
  before { allow(S3Api).to receive(:direct_post).and_return(s3) }

  describe 'GET new' do
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

  describe 'GET show' do
    let(:user) { create(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    let(:issue) { OpenStruct.new(number: 1, title: 'issue_1', body: 'test', labels: [label_1]) }
    let(:label_1) { OpenStruct.new(name: 'techdebt', color: '000') }
    let(:label_2) { OpenStruct.new(name: 'bug', color: '000') }
    before { allow_any_instance_of(GithubApi).to receive(:issues).and_return([issue]) }
    before { allow_any_instance_of(GithubApi).to receive(:labels).and_return([label_1, label_2]) }
    before { allow_any_instance_of(GithubApi).to receive(:collaborators).and_return([]) }
    before do
      allow_any_instance_of(GithubApi).
        to receive(:cached_repos).and_return([])
    end
    before { stub_sign_in(user) }

    it 'returns http success' do
      get :show, github_full_name: board.github_full_name
      expect(response).to have_http_status(:success)
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
