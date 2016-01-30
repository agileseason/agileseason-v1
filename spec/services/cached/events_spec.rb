describe Cached::Events do
  describe '#call' do
    subject { Cached::Events.call(user: user, board: board, number: number) }
    let(:board) { build_stubbed :board, is_private_repo: true }
    let(:number) { 1 }
    let(:cache) { double(write: nil, read: nil) }
    let(:github_api) { double(issue_events: events) }
    let(:events) { [] }
    before { allow(Rails).to receive(:cache).and_return(cache) }
    before { allow(user).to receive(:github_api).and_return(github_api) }
    before { allow(Cached::UpdateBase).to receive(:call).and_return(events) }

    context 'signed in (only)' do
      let(:user) { build_stubbed :user }
      before do
        allow(Boards::DetectRepo).to receive(:call).and_return(OpenStruct.new)
      end

      it { is_expected.to eq events }

      context 'behavior' do
        before { subject }

        it { expect(cache).to have_received(:read) }
        it { expect(github_api).to have_received(:issue_events) }
        it do
          expect(Cached::UpdateBase).
            to have_received(:call).
            with(objects: events, key: "board_bag_events_#{number}_#{board.id}")
        end
      end
    end
  end
end
