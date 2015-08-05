describe Subscriber do
  describe '.early_access' do
    subject(:early_access) { Subscriber.early_access(board, user) }
    let(:user) { create(:user) }

    context 'private board without subscription' do
      let(:board) { create(:kanban_board, :with_columns, user: user) }

      it { expect { subject }.to change(Subscription, :count).by(1) }

      describe 'check subscription' do
        let(:now) { Time.current }
        before { Timecop.freeze(now) }
        after { Timecop.return }

        its(:board) { is_expected.to eq board }
        its(:date_to) { is_expected.to eq now + Subscriber::EARLY_ACCESS_PERIOD }
        its(:cost) { is_expected.to eq 0 }
      end

      describe 'check board' do
        subject { board.reload.subscribed_at }
        before { early_access }

        it { is_expected.not_to be_nil }
        it { is_expected.to eq Subscription.find_by(board: board).date_to }
      end
    end

    context 'private board with subscription' do
      let(:board) do
        create(:board, :with_columns, subscribed_at: subscribed_at, user: user)
      end
      let!(:subscription) do
        create(:subscription, user: user, board: board, date_to: subscribed_at)
      end

      context 'actual subscription' do
        let(:subscribed_at) { Time.current + 1.day }
        it { expect { subject }.not_to change(Subscription, :count) }
        it { is_expected.to eq subscription }
      end

      context 'not actual subscription' do
        let(:subscribed_at) { Time.current - 1.day }

        it { expect { subject }.to change(Subscription, :count).by(1) }
      end
    end
  end
end
