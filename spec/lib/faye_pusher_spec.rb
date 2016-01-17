describe FayePusher do
  let(:board) { build(:board, id: 123) }

  describe '.board_channel' do
    subject { FayePusher.board_channel(board) }
    it { is_expected.to eq "/boards/#{board.id}/update" }
  end
end
