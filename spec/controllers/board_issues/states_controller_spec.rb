describe BoardIssues::StatesController do
  let(:board) { create(:kanban_board, :with_columns, user: user) }
  let(:user) { create(:user) }
  let(:column) { board.columns.first }
  let(:issue_stat) { build(:issue_stat, board: board, column: column) }
  before { stub_sign_in(user) }
  before { allow(controller).to receive(:broadcast_column) }
  before { allow(controller).to receive(:render_board_issue_json).and_return({}) }
  before { allow(Graphs::IssueStatsWorker).to receive(:perform_async) }

  describe '#update' do
    [:html, :json].each do |format|
      context "#{format}" do
        subject do
          patch(:update, params: {
            board_github_full_name: board.github_full_name,
            number: issue_stat.number,
            state: state,
            format: format
          })
        end

        context 'close' do
          let(:state) { 'close' }
          before do
            allow(IssueStats::Closer).to receive(:call).and_return(issue_stat)
          end
          before { subject }


          it { expect(response).to have_http_status(:success) }
          it { expect(Graphs::IssueStatsWorker).to have_received(:perform_async) }
          it do
            expect(controller).
              to have_received(:broadcast_column).with(column, false)
          end
          it do
            expect(IssueStats::Closer).to have_received(:call).with(
              user: user,
              board_bag: anything,
              number: issue_stat.number
            )
          end
        end

        context 'reopen' do
          let(:state) { 'reopen' }
          before do
            allow(IssueStats::Reopener).to receive(:call).and_return(issue_stat)
          end
          before { subject }

          it { expect(response).to have_http_status(:success) }
          it { expect(Graphs::IssueStatsWorker).to have_received(:perform_async) }
          it do
            expect(controller).
              to have_received(:broadcast_column).with(column, false)
          end
          it do
            expect(IssueStats::Reopener).to have_received(:call).with(
              user: user,
              board_bag: anything,
              number: issue_stat.number
            )
          end
        end

        context 'archive' do
          let(:state) { 'archive' }
          before do
            allow(IssueStats::Archiver).
              to receive(:call).and_return(issue_stat)
          end
          before { subject }

          it { expect(response).to have_http_status(:success) }
          it { expect(Graphs::IssueStatsWorker).not_to have_received(:perform_async) }
          it do
            expect(controller).
              to have_received(:broadcast_column).with(column, false)
          end
          it do
            expect(IssueStats::Archiver).to have_received(:call).with(
              user: user,
              board_bag: anything,
              number: issue_stat.number
            )
          end
        end

        context 'unarchive' do
          let(:state) { 'unarchive' }
          before do
            allow(IssueStats::Unarchiver).
              to receive(:call).and_return(issue_stat)
          end
          before { subject }

          it { expect(response).to have_http_status(:success) }
          it { expect(Graphs::IssueStatsWorker).not_to have_received(:perform_async) }
          it do
            expect(controller).
              to have_received(:broadcast_column).with(column, true)
          end
          it do
            expect(IssueStats::Unarchiver).to have_received(:call).with(
              user: user,
              board_bag: anything,
              number: issue_stat.number
            )
          end
        end
      end
    end
  end
end
