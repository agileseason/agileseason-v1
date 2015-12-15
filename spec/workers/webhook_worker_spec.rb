describe WebhookWorker do
  describe '#perform' do
    subject { worker.perform(board.id, token) }
    let(:worker) { WebhookWorker.new }
    let(:token) { 'fake-token' }
    let(:board) { create :board, :with_columns, github_hook_id: nil }
    let(:api) { double(apply_issues_hook: hook) }
    let(:hook) { OpenStruct.new(id: "123") }
    before { allow(worker).to receive(:github_api).and_return api }
    before { subject }

    it { expect(board.reload.github_hook_id).to eq hook.id }
  end
end
