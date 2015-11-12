describe Cached::Labels do
  describe '#call' do
    subject { Cached::Labels.call(user: user, board: board) }
    let(:board) { build :board, is_public: is_public }
    let(:cache) { double(write: nil, read: nil) }
    let(:github_api) { double(labels: labels) }
    let(:labels) { [] }
    before { allow(Rails).to receive(:cache).and_return(cache) }
    before { allow(user).to receive(:github_api).and_return(github_api) }

    context 'guest' do
      let(:user) { build :user, :guest }

      context 'public board' do
        let(:is_public) { true }
        it { is_expected.to be_nil }

        context 'behavior' do
          before { subject }

          it { expect(cache).to have_received(:read) }
          it { expect(github_api).not_to have_received(:labels) }
        end
      end

      context 'private board' do
        let(:is_public) { false }

        it { is_expected.to be_nil }

        context 'behavior' do
          before { subject }

          it { expect(cache).not_to have_received(:read) }
          it { expect(github_api).not_to have_received(:labels) }
        end
      end
    end

    context 'signed in' do
      let(:user) { build_stubbed :user }

      context 'public board' do
        let(:is_public) { true }
        it { is_expected.to eq labels }

        context 'behavior' do
          before { subject }

          it { expect(cache).to have_received(:read) }
          it { expect(github_api).to have_received(:labels) }
        end
      end

      context 'private board' do
        let(:is_public) { false }
        it { is_expected.to be_empty }

        context 'behavior' do
          before { subject }

          it { expect(cache).to have_received(:read) }
          it { expect(github_api).to have_received(:labels) }
        end
      end
    end
  end
end
