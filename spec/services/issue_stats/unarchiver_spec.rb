describe IssueStats::Unarchiver do
  let(:unarchiver) { IssueStats::Unarchiver.new(user, board_bag, issue_stat.number) }
  let(:user) { create(:user) }
  let(:board) { create(:board, :with_columns, user: user) }
  let(:board_bag) { BoardBag.new(nil, board) }

  describe '#call' do
    subject { unarchiver.call }

    context 'issue not archived yet' do
      let(:issue_stat) { create(:issue_stat, board: board) }

      context 'behavior' do
        after { subject }

        it { expect(Activities::UnarchiveActivity).not_to receive(:create_for) }
        it { expect_any_instance_of(IssueStats::LifetimeStarter).not_to receive(:call) }
      end
    end

    context 'archived issue' do
      let(:issue_stat) { create(:issue_stat, :archived, board: board) }

      context 'behavior' do
        after { subject }

        it { expect(Activities::UnarchiveActivity).to receive(:create_for) }
        it { expect_any_instance_of(IssueStats::LifetimeStarter).to receive(:call) }
      end

      context 'result' do
        before { subject }

        it { is_expected.not_to be_nil }
        it { expect(issue_stat.reload).not_to be_archived }
      end
    end
  end

  #describe '.unarchive!' do
    #subject { service.unarchive!(board, issue_stat.number, user) }
    #before { allow(Activities::UnarchiveActivity).to receive(:create_for) }
    #before { allow_any_instance_of(IssueStats::LifetimeStarter).to receive(:call) }
    #let!(:issue_stat) do
      #create(:issue_stat, board: board, number: 1, archived_at: archived_at)
    #end

    #context 'valid' do
      #let(:archived_at) { Time.current }
      #it { is_expected.not_to be_archived }

      #context 'activities' do
        #before { subject }
        #it { expect(Activities::UnarchiveActivity).to have_received(:create_for) }
      #end

      #context 'behavior' do
        #after { subject }
        #it { expect_any_instance_of(IssueStats::LifetimeStarter).to receive(:call) }
      #end
    #end

    #context 'not valid' do
      #let(:archived_at) { nil }
      #it { is_expected.to be_nil }

      #context 'activities' do
        #before { subject }
        #it { expect(Activities::UnarchiveActivity).not_to have_received(:create_for) }
      #end

      #context 'behavior' do
        #after { subject }
        #it { expect_any_instance_of(IssueStats::LifetimeStarter).not_to receive(:call) }
      #end
    #end
  #end

end
