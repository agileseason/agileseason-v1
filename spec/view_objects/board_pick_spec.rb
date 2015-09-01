describe BoardPick do
  describe 'class methods' do
    describe '.default' do
      subject { BoardPick.default }

      its(:name) { is_expected.to eq 'New Board...' }
      its(:link) { is_expected.to eq Rails.application.routes.url_helpers.repos_path }
      its(:issues_count) { is_expected.to eq '&nbsp;' }
    end

    describe '.list_by' do
      subject { BoardPick.list_by(boards) }

      context 'empty' do
        let(:boards) { [] }
        it { is_expected.to have(1).items }
      end

      context 'not empty' do
        let(:boards) { [build(:board, id: 1)] }
        it { is_expected.to have(2).items }
        its('last.id') { is_expected.to be_nil }
      end
    end

    describe '.public_list' do
      subject { BoardPick.public_list }
      let!(:board_1) { create(:board, :with_columns) }
      let!(:board_public) { create(:board, :with_columns, :public) }

      it { is_expected.to have(1).item }
      its('first.id') { is_expected.to eq board_public.id }
    end
  end

  describe 'instance methods' do
    let(:object) { BoardPick.new(board) }

    describe '#name' do
      let(:board) { build(:board, name: 'test_123') }
      subject { object.name }

      it { is_expected.to eq board.name }
    end

    describe '#link' do
      subject { object.link }
      let(:board) { build(:board) }

      it do
        is_expected.
          to eq Rails.application.routes.url_helpers.board_path(board)
      end
    end

    describe '#issues_count' do
      subject { object.issues_count }
      let(:object) { BoardPick.new(board) }

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
