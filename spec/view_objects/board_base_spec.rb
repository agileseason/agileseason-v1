describe BoardBase do
  describe 'class methods' do
    describe '.default' do
      subject { BoardBase.default }

      its(:name) { is_expected.to eq 'New Board...' }
      its(:link) { is_expected.to eq Rails.application.routes.url_helpers.repos_path }
      its(:issues_count) { is_expected.to eq '&nbsp;' }
    end
  end

  describe 'instance methods' do
    let(:object) { BoardBase.new(board) }

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
  end
end
