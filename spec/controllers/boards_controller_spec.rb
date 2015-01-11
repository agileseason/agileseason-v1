describe BoardsController, type: :controller do
  render_views

  describe 'GET new' do
    let(:repo) { OpenStruct.new(id: 1, name: 'foo') }
    before { allow_any_instance_of(GithubApi).to receive(:repos).and_return([repo]) }
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
    let(:label_1) { OpenStruct.new(name: board.columns.first.label_name, color: '000') }
    let(:label_2) { OpenStruct.new(name: 'bug', color: '000') }
    before { allow_any_instance_of(GithubApi).to receive(:all_issues).and_return([issue]) }
    before { allow_any_instance_of(GithubApi).to receive(:labels).and_return([label_1, label_2]) }
    before { stub_sign_in(user) }

    it 'returns http success' do
      get :show, github_name: board.github_name
      expect(response).to have_http_status(:success)
    end
  end
end
