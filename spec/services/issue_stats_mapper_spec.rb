describe IssueStatsMapper do
  let(:mapper) { IssueStatsMapper.new(board) }

  describe '#[issue]' do
    subject { mapper[issue] }
    let(:board) { build_stubbed(:board) }

    context 'first import - only open issues' do
      let(:issue) { OpenStruct.new(number: 1, state: state) }
      before { allow(IssueStatService).to receive(:find_or_create_issue_stat) }
      after { subject }

      context :open do
        let(:state) { 'open' }
        it { expect(IssueStatService).to receive(:find_or_create_issue_stat) }
      end

      context :closed do
        let(:state) { 'closed' }
        it { expect(IssueStatService).to_not receive(:find_or_create_issue_stat) }
      end
    end

    context 'second import' do
      let(:issue) { OpenStruct.new(number: number, state: state) }
      let!(:issue_stat) { create(:issue_stat, number: 2, board: board) }
      after { subject }

      context '- open issues always import' do
        let(:state) { 'open' }
        context ':old issue' do
          let(:number) { issue_stat.number - 1 }
          it { expect(IssueStatService).to receive(:find_or_create_issue_stat) }
        end

        context ':new issue' do
          let(:number) { issue_stat.number + 1 }
          it { expect(IssueStatService).to receive(:find_or_create_issue_stat) }
        end
       end

      context '- closed issues import if number create than max(issue_stats.number)' do
        let(:state) { 'closed' }
        context :true do
          let(:number) { issue_stat.number + 1 }
          it { expect(IssueStatService).to receive(:find_or_create_issue_stat) }
        end

        context :false do
          let(:number) { issue_stat.number - 1 }
          it { expect(IssueStatService).to_not receive(:find_or_create_issue_stat) }
        end
      end
    end
  end
end
