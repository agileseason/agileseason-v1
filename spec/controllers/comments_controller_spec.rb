describe CommentsController do
  let(:user) { create(:user) }
  let(:board) { create(:kanban_board, :with_columns, user: user) }
  let(:body) { 'asdf' }
  let(:number) { 1 }
  let(:issue) { stub_issue(number: number) }
  let(:comment) do
    OpenStruct.new(
      id: 1,
      body: 'test',
      bodyMarkdown: '<p>test</p>',
      created_at: Time.current,
      user: OpenStruct.new(
        id: 101,
        login: 'user-test',
        avatar_url: 'http://user-test/avatar'
      )
    )
  end
  before { stub_sign_in(user) }
  before { allow(Cached::Issues).to receive(:call).and_return([]) }
  before { allow(Cached::Comments).to receive(:call).and_return([]) }
  before { allow(IssueStats::LazySyncChecklist).to receive(:call) }
  before { allow(CheckboxSynchronizer).to receive(:perform_async) }
  before { allow_any_instance_of(BoardBag).to receive(:issue).and_return(issue) }
  before do
    allow_any_instance_of(GithubApi).
      to receive(:update_comment).
      and_return(comment)
  end

  describe '#index' do
    before do
      get(
        :index,
        params: {
          board_github_full_name: board.github_full_name,
          number: number,
          format: :json
        }
      )
    end

    it { expect(response).to have_http_status(:success) }
    it { expect(IssueStats::LazySyncChecklist).to have_received(:call) }
    it { expect(CheckboxSynchronizer).not_to have_received(:perform_async) }
  end

  describe '#create' do
    subject do
      post(
        :create,
        params: {
          board_github_full_name: board.github_full_name,
          number: number,
          id: 101,
          comment: { body: body },
          format: :json
        }
      )
    end
    before do
      allow_any_instance_of(GithubApi).
        to receive(:add_comment).
        and_return(comment)
    end

    context 'check response' do
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it { expect(IssueStats::LazySyncChecklist).not_to have_received(:call) }
      it { expect(CheckboxSynchronizer).to have_received(:perform_async) }
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
        params: {
          board_github_full_name: board.github_full_name,
          number: number,
          id: 101,
          comment: { body: body },
          format: :json
        }
      )
    end

    context 'check response' do
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it { expect(IssueStats::LazySyncChecklist).not_to have_received(:call) }
      it { expect(CheckboxSynchronizer).to have_received(:perform_async) }
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
        params: {
          board_github_full_name: board.github_full_name,
          number: number,
          id: 101,
          format: :json
        }
      )
    end

    context 'check response' do
      before { allow_any_instance_of(GithubApi).to receive(:delete_comment) }
      before { subject }
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template(partial: '_issue_miniature') }
      it { expect(IssueStats::LazySyncChecklist).not_to have_received(:call) }
      it { expect(CheckboxSynchronizer).to have_received(:perform_async) }
    end

    context 'call delete_comment' do
      after { subject }
      it { expect_any_instance_of(GithubApi).to receive(:delete_comment).once }
    end
  end

  describe 'permissions' do
    subject { Ability.new user }
    let(:user) { build_stubbed :user }
    before { allow(Boards::DetectRepo).to receive(:call).and_return nil }

    describe 'manage_comments' do
      let(:board) { build(:board, user: owner_board, is_public: is_public) }
      let(:comment) { double(user: double(login: user.github_username)) }
      let(:is_public) { false }

      context 'owner' do
        let(:owner_board) { user }
        it { is_expected.to be_able_to(:manage_comments, board, comment) }
      end

      context 'author but board private' do
        let(:owner_board) { build_stubbed :user }
        it { is_expected.not_to be_able_to(:manage_comments, board, comment) }
      end

      context 'author and public board' do
        let(:owner_board) { build_stubbed :user }
        let(:is_public) { true }

        it { is_expected.to be_able_to(:manage_comments, board, comment) }
      end
    end
  end
end
