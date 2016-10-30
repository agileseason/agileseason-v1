describe Boards::Create do
  subject do
    Boards::Create.call(
      user: user,
      board_params: board_params,
      columns_params: columns_params,
      encrypted_github_token: token
    )
  end
  let(:user) { create :user }
  let(:token) { '123' }
  let(:board_params) do
    {
      name: board_name,
      type: 'Boards::KanbanBoard',
      github_id: '123',
      github_name: 'test-1',
      github_full_name: 'test/test-1',
      is_private_repo: false,
    }
  end
  let(:board_name) { 'test-1' }
  let(:columns_params) { { name: ['c-1', 'c-2'] } }
  let(:issue_stat_worker) { double(perform: nil) }
  before { allow(WebhookWorker).to receive(:perform_async) }
  before do
    allow(Graphs::IssueStatsWorker).to receive(:new).and_return(issue_stat_worker)
  end

  describe 'success' do
    it { is_expected.to be_persisted }
    its(:name) { is_expected.to eq board_name }
    its(:columns) { is_expected.to have(2).items }
    its(:private_repo?) { is_expected.to eq false }
    its('columns.first.name') { is_expected.to eq 'c-1' }
    its('columns.first.order') { is_expected.to eq 1 }
    its('columns.second.name') { is_expected.to eq 'c-2' }
    its('columns.second.order') { is_expected.to eq 2 }

    describe 'behavior' do
      before { subject }
      it do
        expect(WebhookWorker).
          to have_received(:perform_async).with(anything, token)
      end
      it do
        expect(issue_stat_worker).
          to have_received(:perform).with(anything, token)
      end
    end
  end

  describe 'not success' do
    context 'board name is invalid' do
      let(:board_name) { '' }
      it { is_expected.not_to be_persisted }

      describe 'behavior' do
        before { subject }
        it { expect(WebhookWorker).not_to have_received(:perform_async) }
        it { expect(issue_stat_worker).not_to have_received(:perform) }
      end
    end

    context 'too few columns' do
      let(:columns_params) { { name: ['c-1'] } }
      it { is_expected.not_to be_persisted }

      describe 'behavior' do
        before { subject }
        it { expect(WebhookWorker).not_to have_received(:perform_async) }
        it { expect(issue_stat_worker).not_to have_received(:perform) }
      end
    end
  end
end
