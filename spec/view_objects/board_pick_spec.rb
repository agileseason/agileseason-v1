describe BoardPick do
  describe 'class methods' do
    describe '.default' do
      subject { BoardPick::DEFAULT }

      its(:name) { is_expected.to eq 'New Board...' }
      its(:link) { is_expected.to eq Rails.application.routes.url_helpers.repos_path }
      its(:issues_count) { is_expected.to eq '&nbsp;' }
    end

    describe '.list_by' do
      subject { BoardPick.list_by(user, boards) }
      let(:signed_user) { build_stubbed :user }
      let(:guest_user) { build :user, :guest }

      context 'empty' do
        let(:boards) { [] }

        context 'guest' do
          let(:user) { guest_user }
          it { is_expected.to be_empty }
        end

        context 'not guest' do
          let(:user) { signed_user }
          it { is_expected.to have(1).items }
        end
      end

      context 'not empty (user can`t be guest)' do
        let(:user) { signed_user }
        let(:boards) { [build(:board, id: 1)] }

        it { is_expected.to have(2).items }
        its('last.id') { is_expected.to be_nil }
      end
    end

    describe '.public_list' do
      subject { BoardPick.public_list }
      let!(:board_1) { create(:board, :with_columns) }
      let!(:board_public_1) { create(:board, :with_columns, :public, name: 'bbb') }
      let!(:board_public_2) { create(:board, :with_columns, :public, name: 'aaa') }

      it { is_expected.to have(2).item }
      its('first.id') { is_expected.to eq board_public_2.id }
      its('second.id') { is_expected.to eq board_public_1.id }
    end
  end

  describe 'instance methods' do
    let(:board_pick) { BoardPick.new(board) }

    describe '#name' do
      let(:board) { build(:board, name: 'test_123') }
      subject { board_pick.name }

      it { is_expected.to eq board.name }
    end

    describe '#link' do
      subject { board_pick.link }
      let(:board) { build(:board) }

      it do
        is_expected.
          to eq Rails.application.routes.url_helpers.board_path(board)
      end
    end

    describe '#issues_count' do
      subject { board_pick.issues_count }
      let(:board_pick) { BoardPick.new(board) }

      context 'empty' do
        let(:board) { build(:board) }
        it { is_expected.to eq '0 open issues' }
      end

      context 'with issues open, closed and archived' do
        let(:board) { create(:board, :with_columns) }
        let!(:issues_1) { create(:issue_stat, :open, board: board) }
        let!(:issues_2) { create(:issue_stat, :closed, board: board) }
        let!(:issues_3) { create(:issue_stat, :archived, board: board) }

        it { is_expected.to eq '1 open issues' }
      end
    end
  end
end
