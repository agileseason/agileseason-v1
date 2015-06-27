describe FayePusher do
  let(:board) { build(:board, id: 123) }

  describe '.board_channel' do
    subject { FayePusher.board_channel(board) }

    it { is_expected.to eq "/boards/#{board.id}/update" }
  end

  describe '.issue_channel' do
    subject { FayePusher.issue_channel(board) }

    it { is_expected.to eq "/boards/#{board.id}/issues" }
  end

  describe '.broadcast_issue' do
    subject { FayePusher.broadcast_issue(user, board, data) }
    let(:user) { build(:user) }
    let(:board) { build(:board, id: 1001, user: user) }
    let(:data) { { message: 'test' } }
    let(:chanel) { "/boards/#{board.id}/issues" }

    after { subject }

    it do
      expect(FayePusher).
        to receive(:broadcast).with(chanel, user, data)
    end
  end
end
