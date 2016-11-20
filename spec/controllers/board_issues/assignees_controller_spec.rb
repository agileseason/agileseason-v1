describe BoardIssues::AssigneesController do
  let(:board) { create(:kanban_board, :with_columns, user: user) }
  let(:user) { create(:user) }
  let(:issue_stat) { build(:issue_stat, board: board) }
  before { stub_sign_in(user) }
  before { allow(controller).to receive(:render_board_issue_json).and_return({}) }

  describe '#update' do
    subject do
      patch(:update, params: {
        board_github_full_name: board.github_full_name,
        number: issue_stat.number,
        login: 'github_user',
      })
    end

    context 'response' do
      before { allow(IssueStats::Assigner).to receive(:call) }
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it do
        expect(IssueStats::Assigner).
          to have_received(:call).
          with(
            user: user,
            board_bag: anything,
            number: issue_stat.number,
            login: 'github_user'
          )
      end
    end
  end
end
