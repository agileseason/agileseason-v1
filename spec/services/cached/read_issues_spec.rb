describe Cached::ReadIssues do
  describe '#call' do
    subject { Cached::ReadIssues.call(board: board) }
    let(:board) { build_stubbed :board }
    before { allow(Cached::ReadBase).to receive(:call) }
    before { subject }

    it do
      expect(Cached::ReadBase).
        to have_received(:call).
        with(key: "board_bag_issues_hash_#{board.id}")
    end
  end
end

