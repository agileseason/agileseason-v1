describe Cached::Comments do
  describe '#call' do
    subject { Cached::Comments.call(user: user, board: board, number: number) }
    let(:board) { build_stubbed :board, is_public: is_public }
    let(:number) { 1 }
    let(:cache) { double(write: nil, read: nil) }
    let(:github_api) { double(issue_comments: comments) }
    let(:comments) { [] }
    before { allow(Rails).to receive(:cache).and_return(cache) }
    before { allow(user).to receive(:github_api).and_return(github_api) }
    before { allow(Cached::UpdateBase).to receive(:call).and_return(comments) }

    context 'guest' do
      let(:user) { build :user, :guest }

      context 'public board' do
        let(:is_public) { true }
        it { is_expected.to eq Cached::Comments::NO_DATA }

        context 'behavior' do
          before { subject }

          it do
            expect(cache).
              to have_received(:read).
              with("board_bag_comments_#{number}_#{board.id}")
          end
          it { expect(github_api).not_to have_received(:issue_comments) }
        end
      end

      context 'private board' do
        let(:is_public) { false }
        it { is_expected.to eq comments }

        context 'behavior' do
          before { subject }

          it { expect(cache).not_to have_received(:read) }
          it { expect(github_api).to have_received(:issue_comments) }
        end
      end
    end

    context 'signed in' do
      let(:user) { build_stubbed :user }
      before { allow(Boards::DetectRepo).to receive(:call).and_return(OpenStruct.new) }

      context 'public board' do
        let(:is_public) { true }
        it { is_expected.to eq comments }

        context 'behavior' do
          before { subject }

          it do
            expect(cache).
              to have_received(:read).
              with("board_bag_comments_#{number}_#{board.id}")
          end
          it { expect(github_api).to have_received(:issue_comments) }
        end
      end

      context 'private board' do
        let(:is_public) { false }
        it { is_expected.to be_empty }

        context 'behavior' do
          before { subject }

          it { expect(cache).not_to have_received(:read) }
          it { expect(Cached::UpdateBase).not_to have_received(:call) }
          it { expect(github_api).to have_received(:issue_comments) }
        end
      end
    end

  end
end
