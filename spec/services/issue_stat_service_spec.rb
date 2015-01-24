describe IssueStatService do
  let(:board) { create(:board, :with_columns, number_of_columns: 2) }
  let(:service) { IssueStatService }
  describe '.create!' do
    subject { service.create!(board, issue) }
    let(:issue) { OpenStruct.new(number: 1, created_at: Time.current, updated_at: Time.current) }
    let(:first_column) { board.columns.first }

    it { is_expected.to be_persisted }
    it { expect(subject.number).to eq issue.number }
    it { expect(subject.created_at).to eq issue.created_at }
    it { expect(subject.updated_at).to eq issue.updated_at }
    it { expect(subject.closed_at).to eq issue.closed_at }
    it { expect{subject}.to change(Lifetime, :count).by(1) }
    it { expect(subject.lifetimes.first.column).to eq first_column }
    it { expect(subject.lifetimes.first.in_at).to_not be_nil }
    it { expect(subject.lifetimes.first.out_at).to be_nil }
  end

  describe '.move' do
    subject { service.move!(board, column, issue) }
    let(:issue) { OpenStruct.new(number: 1) }
    let(:column) { board.columns.second }

    context 'Without IssueStat - create bouth' do
      it { is_expected.to be_persisted }
      it { expect(subject.lifetimes).to have(2).items }
      it { expect(subject.lifetimes.last.column).to eq column }
      it { expect(subject.lifetimes.last.out_at).to be_nil }
      it { expect(subject.lifetimes.first.out_at).to_not be_nil }
    end

    context 'With IssueStat' do
      let!(:issue_stat) { create(:issue_stat, board: board, number: issue.number) }
      it { expect{subject}.to change(Lifetime, :count).by(1) }
    end
  end

  describe '.archive!' do
    let(:issue) { OpenStruct.new(number: 1) }
    subject { service.archive!(board, issue) }

    context :with_issue_stat do
      let!(:issue_stat) { create(:issue_stat, board: board, number: issue.number, archived_at: nil) }
      it { expect{subject}.to change(IssueStat, :count).by(0) }

      context 'lifetime update out_at' do
        let!(:lifetime_1) { create(:lifetime, issue_stat: issue_stat, column: board.columns.first, out_at: nil) }
        before { subject }
        it { expect(lifetime_1.reload.out_at).to_not be_nil }
      end

      context 'set archived_at' do
        before { subject }
        it { expect(issue_stat.reload.archived_at).to_not be_nil }
      end
    end

    context :without_issue_stat do
      it { expect{subject}.to change(IssueStat, :count).by(1) }
    end
  end

  describe '.archived?' do
    subject { service.archived?(board, number) }
    let(:issue_stat) { create(:issue_stat, board: board, number: 1, archived_at: archived_at) }
    let(:number) { issue_stat.number }
    let(:archived_at) { nil }

    context :unknown do
      let(:number) { issue_stat.number + 1 }
      it { is_expected.to be_nil }
    end

    context :true do
      let(:archived_at) { Time.current }
      it { is_expected.to_not be_nil }
    end

    context :false do
      it { is_expected.to be_nil }
    end
  end
end
