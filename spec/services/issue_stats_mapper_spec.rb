describe IssueStatsMapper do
  let(:mapper) { IssueStatsMapper.new(BoardBag.new(user, board)) }
  let(:user) { build_stubbed(:user) }
  before { allow(Boards::DetectRepo).to receive(:call).and_return(OpenStruct.new) }

  describe '#[issue]' do
    subject { mapper[issue] }
    let(:board) { build_stubbed(:board, user: user) }

    context 'not fix missings for - ' do
      let(:issue) { stub_issue }

      context 'guest' do
        let(:user) { build :user, :guest }
        it { is_expected.to be_nil }
      end

      context 'signed user without permissions' do
        let(:user) { build_stubbed :user }
        let(:board) { build_stubbed :board }
        before { allow(Boards::DetectRepo).to receive(:call) }

        it { is_expected.to be_nil }
      end
    end

    context 'first import - only open issues' do
      let(:issue) { stub_issue(state: state) }
      after { subject }

      context :open do
        let(:state) { 'open' }
        it { expect(IssueStatService).to receive(:create) }
      end

      context :closed do
        let(:state) { 'closed' }
        it { expect(IssueStatService).not_to receive(:create) }
      end
    end

    context 'second import' do
      let(:issue) { stub_issue(number: number, state: state) }
      let!(:issue_stat) { create(:issue_stat, number: 2, board: board) }
      after { subject }

      context '- open issues always import' do
        let(:state) { 'open' }
        context ':old issue' do
          let(:number) { issue_stat.number - 1 }
          it { expect(IssueStatService).to receive(:create) }
        end

        context ':new issue' do
          let(:number) { issue_stat.number + 1 }
          it { expect(IssueStatService).to receive(:create) }
        end
      end

      context '- closed issues import if number create than max(issue_stats.number)' do
        let(:state) { 'closed' }
        context :true do
          let(:number) { issue_stat.number + 1 }
          it { expect(IssueStatService).to receive(:create) }
        end

        context :false do
          let(:number) { issue_stat.number - 1 }
          it { expect(IssueStatService).not_to receive(:create) }
        end
      end
    end
  end
end
