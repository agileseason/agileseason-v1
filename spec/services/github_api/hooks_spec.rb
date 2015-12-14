describe GithubApi::Hooks do
  let(:api) { GithubApi.new('fake_token') }
  let(:board) { build :board }
  before { allow(api).to receive(:client).and_return client }

  describe '#hook' do
    subject { api.hook(board, hook_id) }
    let(:client) { double(hook: nil) }
    before { subject }

    context 'with id' do
      let(:hook_id) { 1 }
      it { expect(client).to have_received(:hook).with(board.github_id, hook_id) }
    end

    context 'without id' do
      let(:hook_id) {}
      it { expect(client).not_to have_received(:hook) }
    end
  end

  describe '#hooks' do
    subject { api.hooks(board) }
    let(:client) { double(hooks: []) }
    before { subject }

    it { expect(client).to have_received(:hooks).with(board.github_id) }
  end

  describe '#apply_issues_hook' do
    subject { api.apply_issues_hook(board) }
    before { subject }

    context 'hook already init' do
      let(:board) { create :board, :with_columns, github_hook_id: '1' }
      let(:client) { double(hook: hook) }
      let(:hook) { OpenStruct.new(id: board.github_hook_id) }

      it { expect(client).to have_received(:hook).with(board.github_id, hook.id) }
      it { expect(board.reload.github_hook_id).to eq hook.id }
    end

    context 'hook not init but exists' do
      subject { api.apply_issues_hook(board) }
      let(:board) { create :board, :with_columns, github_hook_id: nil }
      let(:client) { double(hooks: hooks) }
      let(:hooks) { [hook_1, hook_2] }
      let(:hook_1) { OpenStruct.new(id: '1', config: OpenStruct.new(url: '')) }
      let(:hook_2) { OpenStruct.new(id: '2', config: OpenStruct.new(url: 'https://agileseason.com/webhooks/github')) }
      before { subject }

      it { expect(client).to have_received(:hooks).with(board.github_id) }
      it { expect(board.reload.github_hook_id).to eq hook_2.id }
    end
  end

  describe '#remove_issue_hook' do
    subject { api.remove_issue_hook(board) }
    let(:board) { create(:board, :with_columns, github_hook_id: 123) }
    let(:client) { double(remove_hook: nil) }
    before { subject }

    it { expect(board.reload.github_hook_id).to be_nil }
  end
end
