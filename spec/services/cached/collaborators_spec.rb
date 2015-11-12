describe Cached::Collaborators do
  describe '#call' do
    subject { Cached::Collaborators.call(user: user, board: board) }
    let(:board) { build_stubbed :board, is_public: is_public }
    let(:cache) { double(write: nil, read: nil) }
    let(:github_api) { double(collaborators: collaborators) }
    let(:collaborators) { [] }
    before { allow(Rails).to receive(:cache).and_return(cache) }
    before { allow(user).to receive(:github_api).and_return(github_api) }

    context 'guest' do
      let(:user) { build :user, :guest }

      context 'public board' do
        let(:is_public) { true }
        it { is_expected.to be_nil }

        context 'behavior' do
          before { subject }

          it do
            expect(cache).
              to have_received(:read).
              with("board_bag_collaborators_#{board.id}")
          end
          it { expect(github_api).not_to have_received(:collaborators) }
        end
      end

      context 'private board' do
        let(:is_public) { false }

        it { is_expected.to be_nil }

        context 'behavior' do
          before { subject }

          it { expect(cache).not_to have_received(:read) }
          it { expect(github_api).not_to have_received(:collaborators) }
        end
      end
    end

    context 'signed in' do
      let(:user) { build_stubbed :user }

      context 'public board' do
        let(:is_public) { true }
        it { is_expected.to eq collaborators }

        context 'behavior' do
          before { subject }

          it do
            expect(cache).
              to have_received(:read).
              with("board_bag_collaborators_#{board.id}")
          end
          it { expect(github_api).to have_received(:collaborators) }
        end
      end

      context 'private board' do
        let(:is_public) { false }
        it { is_expected.to be_empty }

        context 'behavior' do
          let(:now) { Time.current }
          let(:cached_object) { Cached::Base.new(collaborators, now) }
          before { allow(Cached::Base).to receive(:new).and_return(cached_object) }
          before { Timecop.freeze(now) }
          before { subject }
          after { Timecop.return }

          it do
            expect(cache).
              to have_received(:read).
              with("board_bag_collaborators_#{board.id}")
          end
          it do
            expect(cache).
              to have_received(:write).
              with(
                "board_bag_collaborators_#{board.id}",
                cached_object,
                expires_in: Cached::ItemsBase::READONLY_EXPIRES_IN
              )
          end
          it { expect(github_api).to have_received(:collaborators) }
        end
      end
    end
  end
end

