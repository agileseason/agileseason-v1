describe Graphs::CumulativeController, type: :controller do
  describe '#index' do
    subject do
      get(:index, params: {
        board_github_full_name: board.github_full_name, interval: interval
      })
    end
    let(:user) { create(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    let(:interval) {}
    let(:is_owner) { true }
    before { allow(Graphs::CumulativeWorker).to receive(:perform_async) }
    before do
      allow_any_instance_of(BoardBag).
        to receive(:has_write_permission?).
        and_return(is_owner)
    end
    before { stub_sign_in(user) }

    context 'responce' do
      before { subject }

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template(:index) }

      context 'with interval: month' do
        let(:interval) { :month }
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to render_template(:index) }
      end

      context 'with interval: all' do
        let(:interval) { :all }
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to render_template(:index) }
      end
    end

    context 'behavior' do
      before { board_history }
      before { subject }

      context 'without permissions' do
        let(:is_owner) { false }
        let(:board_history) {}

        it { expect(Graphs::CumulativeWorker).not_to have_received(:perform_async) }
      end

      context 'without board history' do
        let(:board_history) { create(:board_history, board: board, collected_on: 1.day.ago) }

        it { expect(Graphs::CumulativeWorker).to have_received(:perform_async) }
      end

      context 'with board history' do
        let(:board_history) { create(:board_history, board: board, collected_on: Date.today) }

        it { expect(Graphs::CumulativeWorker).not_to have_received(:perform_async) }
      end
    end
  end
end
