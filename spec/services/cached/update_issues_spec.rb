describe Cached::UpdateIssues do
  describe '#call' do
    subject { Cached::UpdateIssues.call(board: board, objects: issues) }
    let(:board) { build_stubbed :board }
    let(:issues) { {} }
    before { allow(Cached::UpdateBase).to receive(:call) }
    before { subject }

    it do
      expect(Cached::UpdateBase).
        to have_received(:call).
        with(objects: issues, key: "board_bag_issues_hash_#{board.id}")
    end
  end
end
