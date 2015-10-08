describe CommentsController do
  let(:user) { create(:user) }
  let(:board) { create(:kanban_board, :with_columns, user: user) }
  let(:body) { 'asdf' }
  let(:number) { 1 }
  before { stub_sign_in(user) }
  before { allow_any_instance_of(GithubApi).to receive(:issues).and_return([]) }
  before { allow_any_instance_of(GithubApi).to receive(:issue_comments).and_return([]) }
  before { allow(IssueStats::SyncChecklist).to receive(:call) }

  describe '#index' do
    before do
      get(
        :index,
        board_github_full_name: board.github_full_name,
        number: number
      )
    end

    it { expect(response).to have_http_status(:success) }
  end

  describe '#create' do
    subject do
      post(
        :create,
        board_github_full_name: board.github_full_name,
        number: number,
        id: 101,
        comment: { body: body }
      )
    end

    context 'check response' do
      before { allow_any_instance_of(GithubApi).to receive(:add_comment) }
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it { expect(response.body).to be_empty }
      it { expect(IssueStats::SyncChecklist).to have_received(:call) }
    end

    context 'call add_comment in github_api' do
      after { subject }
      it { expect_any_instance_of(GithubApi).to receive(:add_comment) }
    end
  end

  describe '#update' do
    subject do
      post(
        :update,
        board_github_full_name: board.github_full_name,
        number: number,
        id: 101,
        comment: { body: body }
      )
    end

    context 'check response' do
      before { allow_any_instance_of(GithubApi).to receive(:update_comment) }
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it { expect(response.body).to be_empty }
      it { expect(IssueStats::SyncChecklist).to have_received(:call) }
    end

    context 'call update_comment in github_api' do
      after { subject }
      it { expect_any_instance_of(GithubApi).to receive(:update_comment) }
    end
  end

  describe '#delete' do
    subject do
      delete(
        :delete,
        board_github_full_name: board.github_full_name,
        number: number,
        id: 101
      )
    end

    context 'check response' do
      before { allow_any_instance_of(GithubApi).to receive(:delete_comment) }
      before { subject }
      it { expect(response).to have_http_status(:success) }
      it { expect(response.body).to be_empty }
    end

    context 'call delete_comment' do
      after { subject }
      it { expect_any_instance_of(GithubApi).to receive(:delete_comment).once }
    end
  end
end
