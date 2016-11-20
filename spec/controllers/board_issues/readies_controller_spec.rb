describe BoardIssues::ReadiesController do
  let(:board) { create(:kanban_board, :with_columns, user: user) }
  let(:user) { create(:user) }
  let(:column) { board.columns.first }
  let(:issue_stat) do
    build(:issue_stat, board: board, column: column, is_ready: is_ready)
  end
  before { stub_sign_in(user) }
  before { allow(controller).to receive(:broadcast_column) }
  before { allow(controller).to receive(:render_board_issue_json).and_return({}) }

  describe '#update' do
    subject do
      patch(:update, params: {
        board_github_full_name: board.github_full_name,
        number: issue_stat.number
      })
    end
    before do
      allow_any_instance_of(IssueStats::Finder).
        to receive(:call).and_return(issue_stat)
    end
    before { allow(IssueStats::Unready).to receive(:call) }
    before { allow(IssueStats::Ready).to receive(:call) }
    before { subject }

    context 'true' do
      let(:is_ready) { true }

      it { expect(response).to have_http_status(:success) }
      it do
        expect(controller).
          to have_received(:broadcast_column).with(issue_stat.column)
      end
      it do
        expect(IssueStats::Unready).
          to have_received(:call).
          with(
            user: user,
            board_bag: anything,
            number: issue_stat.number
          )
      end
      it { expect(IssueStats::Ready).not_to have_received(:call) }
    end

    context 'flase' do
      let(:is_ready) { false }

      it { expect(response).to have_http_status(:success) }
      it do
        expect(controller).
          to have_received(:broadcast_column).with(issue_stat.column)
      end
      it { expect(IssueStats::Unready).not_to have_received(:call) }
      it do
        expect(IssueStats::Ready).
          to have_received(:call).
          with(
            user: user,
            board_bag: anything,
            number: issue_stat.number
          )
      end
    end
  end
end
