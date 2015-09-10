describe IssueStatService do
  let(:user) { create(:user) }
  let(:board) do
    create(:board, :with_columns, number_of_columns: 2, user: user)
  end
  let(:service) { IssueStatService }

  describe '.create!' do
    subject { service.create!(board, issue, user) }
    let(:issue) { stub_issue }
    let(:first_column) { board.columns.first }
    before { allow_any_instance_of(IssueStats::LifetimeStarter).to receive(:call) }
    before { allow_any_instance_of(IssueStats::Sorter).to receive(:call) }

    it { is_expected.to be_persisted }
    its(:number) { is_expected.to eq issue.number }
    its(:created_at) { is_expected.to eq issue.created_at }
    its(:updated_at) { is_expected.to eq issue.updated_at }
    its(:closed_at) { is_expected.to eq issue.closed_at }
    its(:column) { is_expected.to eq board.columns.first }

    context 'behavior' do
      after { subject }

      it { expect_any_instance_of(IssueStats::LifetimeStarter).to receive(:call) }
      it { expect_any_instance_of(IssueStats::Sorter).to receive(:call) }
    end
  end

  describe '.close!' do
    let(:issue) { stub_closed_issue }
    subject { service.close!(board, issue, user) }

    context :with_issue_stat do
      let!(:issue_stat) do
        create(:issue_stat, :open, board: board, number: issue.number)
      end

      it { expect { subject }.to change(IssueStat, :count).by(0) }
      it { is_expected.to_not be_nil }
      it { expect(subject.closed_at).to_not be_nil }

      context 'issue already closed' do
        let(:issue) { stub_issue(closed_at: 1.day.ago) }
        it { expect(subject.closed_at).to eq issue.closed_at }
      end
    end

    context :without_issue_stat do
      it { expect { subject }.to change(IssueStat, :count).by(1) }
    end
  end

  describe '.unarchive!' do
    subject { service.unarchive!(board, issue_stat.number, user) }
    before { allow(Activities::UnarchiveActivity).to receive(:create_for) }
    before { allow_any_instance_of( IssueStats::LifetimeStarter).to receive(:call) }
    let!(:issue_stat) do
      create(:issue_stat, board: board, number: 1, archived_at: archived_at)
    end

    context 'valid' do
      let(:archived_at) { Time.current }
      it { is_expected.not_to be_archived }

      context 'activities' do
        before { subject }
        it { expect(Activities::UnarchiveActivity).to have_received(:create_for) }
      end

      context 'behavior' do
        after { subject }
        it { expect_any_instance_of(IssueStats::LifetimeStarter).to receive(:call) }
      end
    end

    context 'not valid' do
      let(:archived_at) { nil }
      it { is_expected.to be_nil }

      context 'activities' do
        before { subject }
        it { expect(Activities::UnarchiveActivity).not_to have_received(:create_for) }
      end

      context 'behavior' do
        after { subject }
        it { expect_any_instance_of(IssueStats::LifetimeStarter).not_to receive(:call) }
      end
    end
  end

  describe '.archive!' do
    let(:issue) { stub_issue }
    subject { service.archive!(board, issue, user) }
    before { allow(Activities::ArchiveActivity).to receive(:create_for) }

    context :with_issue_stat do
      let!(:issue_stat) do
        create(
          :issue_stat,
          board: board,
          number: issue.number,
          archived_at: nil
        )
      end

      it { expect { subject }.to change(IssueStat, :count).by(0) }

      context 'behavior' do
        after { subject }
        it { expect_any_instance_of(IssueStats::LifetimeFinisher).to receive(:call) }
      end

      context 'set archived_at' do
        before { subject }
        it { expect(issue_stat.reload.archived_at).to_not be_nil }
      end
    end

    context :without_issue_stat do
      it { expect { subject }.to change(IssueStat, :count).by(1) }
    end

    context 'create activities' do
      before { subject }

      context 'not skip, user present' do
        let(:user) { create(:user) }
        it { expect(Activities::ArchiveActivity).to have_received(:create_for) }
      end

      context 'not skip, user present' do
        let(:user) { nil }
        it do
          expect(Activities::ArchiveActivity).
            not_to have_received(:create_for)
        end
      end
    end
  end

  describe '.archived?' do
    subject { service.archived?(board, number) }
    let(:issue_stat) do
      create(:issue_stat, board: board, number: 1, archived_at: archived_at)
    end
    let(:number) { issue_stat.number }
    let(:archived_at) { nil }

    context :unknown do
      let(:number) { issue_stat.number + 1 }
      it { is_expected.to be_nil }
    end

    context :true do
      let(:archived_at) { Time.current }
      it { is_expected.to eq true }
    end

    context :false do
      it { is_expected.to eq false }
    end
  end

  describe '.set_due_date' do
    subject { service.set_due_date(user, board, number, new_due_date) }
    let!(:issue_stat) do
      create(
        :issue_stat,
        board: board,
        number: number,
        due_date_at: due_date_at
      )
    end
    let(:number) { 1 }
    let(:due_date_at) { nil }

    context 'check data' do
      before do
        allow(Activities::ChangeDueDate).
          to receive(:create_for)
      end

      context 'from nil to nil' do
        let(:new_due_date) { nil }
        it { expect(subject.due_date_at).to be_nil }
      end

      context 'from nil to due_date' do
        let(:new_due_date) { DateTime.now }
        it { expect(subject.due_date_at).to eq new_due_date }
      end

      context 'from due_date to new due_date' do
        let(:due_date_at) { DateTime.now }
        let(:new_due_date) { DateTime.yesterday }

        it { expect(subject.due_date_at).to eq new_due_date }
      end

      context 'from due_date to nil' do
        let(:due_date_at) { DateTime.now }
        let(:new_due_date) { nil }

        it { expect(subject.due_date_at).to be_nil }
      end
    end

    context 'call create activity' do
      let(:new_due_date) { DateTime.now }
      after { subject }

      it do
        expect(Activities::ChangeDueDate).
          to receive(:create_for).with(issue_stat, user)
      end
    end
  end

  describe '.find_or_build_issue_stat' do
    subject { service.find_or_build_issue_stat(board, issue) }
    let(:issue) { stub_issue }

    it { is_expected.not_to be_nil }
    it { is_expected.not_to be_persisted }
    its(:board_id) { is_expected.to eq board.id }
    its(:number) { is_expected.to eq issue.number }
  end
end
