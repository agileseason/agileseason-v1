describe BoardIssues::LabelsController do
  let(:issue) { stub_issue }
  let(:user) { create(:user) }
  let(:board) { create(:kanban_board, :with_columns, user: user) }
  let(:github_api) { GithubApi.new('fake_token', user) }
  before { stub_sign_in(user) }
  before { allow(Cached::Issues).to receive(:call).and_return([]) }
  before { allow(controller).to receive(:github_api).and_return(github_api) }
  before { allow(github_api).to receive(:update_issue).and_return(issue) }
  before { allow(Boards::DetectRepo).to receive(:call).and_return(stub_repo) }

  describe '#update' do
    subject do
      patch(
        :update,
        params: {
          board_github_full_name: board.github_full_name,
          number: issue.number,
          issue: params
        }
      )
    end
    let(:params) { { labels: ['label-1', 'label-2'] } }

    context 'direct' do
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it do
        expect(github_api).
          to have_received(:update_issue).
          with(board, issue.number, params)
      end
    end

    context 'cache' do
      after { subject }

      it do
        expect_any_instance_of(BoardBag).
          to receive(:update_cache).with(issue)
      end
    end
  end
end
