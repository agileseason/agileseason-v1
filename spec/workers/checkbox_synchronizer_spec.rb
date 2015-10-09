describe CheckboxSynchronizer do
  let(:worker) { CheckboxSynchronizer.new }

  describe '.perform' do
    subject { worker.perform(board.id, number, Encryptor.encrypt('fake_token')) }
    let(:board) { create(:board, :with_columns) }
    let(:number) { 101 }
    let(:comments) { [] }
    before { allow_any_instance_of(GithubApi).to receive(:issue_comments).and_return(comments) }
    before { allow(IssueStats::SyncChecklist).to receive(:call) }

    context 'with issue_stat' do
      let!(:issue_stat) { create(:issue_stat, board: board, number: number) }
      before { subject }

      it do
        expect(IssueStats::SyncChecklist).
          to have_received(:call).
          with(issue_stat: issue_stat, comments: comments)
      end
    end

    context 'without issue_stat' do
      before { subject }

      it do
        expect(IssueStats::SyncChecklist).
          not_to have_received(:call)
      end
    end
  end
end
