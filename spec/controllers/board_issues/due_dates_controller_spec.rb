describe BoardIssues::DueDatesController do
  let(:user) { create(:user) }
  let(:board) { create(:kanban_board, :with_columns, user: user) }
  before { stub_sign_in(user) }
  before { allow(controller).to receive(:broadcast_column) }
  before { allow(controller).to receive(:render_board_issue_json).and_return({}) }

  describe '#update' do
    subject do
      patch(:update, params: {
        board_github_full_name: board.github_full_name,
        number: issue_stat.number,
        due_date: date
      })
    end
    let(:date) { '10/11/2015 12:00' }
    let(:issue_stat) do
      create(:issue_stat, board: board, due_date_at: nil, column: column)
    end
    let(:column) { board.columns.first }
    before { subject }

    it { expect(response).to have_http_status(:success) }
    it { expect(issue_stat.reload.due_date_at).to eq date }
    it { expect(controller).to have_received(:broadcast_column).with(column) }
  end
end
