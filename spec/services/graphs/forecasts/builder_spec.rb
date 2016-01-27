describe Graphs::Forecasts::Builder do
  describe '#call' do
    subject { builder.call }
    let(:builder) { Graphs::Forecasts::Builder.new(issues, intervals) }
    let(:intervals) do
      [
        (1.week.ago.beginning_of_week..1.week.ago.end_of_week),
        (Time.current.beginning_of_week..Time.current.end_of_week)
      ]
    end

    context 'without issues' do
      let(:issues) { [] }
      it { is_expected.to have(2).items }
      its('first.open') { is_expected.to eq 0 }
      its('first.closed') { is_expected.to eq 0 }
      its('second.open') { is_expected.to eq 0 }
      its('second.closed') { is_expected.to eq 0 }
    end

    context 'one issue in last week' do
      let(:issues) { [issue] }
      let(:issue) { stub_issue(created_at: created_at, closed_at: closed_at) }
      let(:created_at) { Time.current.beginning_of_week + 1.second }

      context 'open' do
        let(:closed_at) { nil }

        it { is_expected.to have(2).items }
        its('first.open') { is_expected.to eq 0 }
        its('first.closed') { is_expected.to eq 0 }
        its('second.open') { is_expected.to eq 1 }
        its('second.closed') { is_expected.to eq 0 }
      end

      context 'closed' do
        let(:closed_at) { created_at + 1.second }

        it { is_expected.to have(2).items }
        its('first.open') { is_expected.to eq 0 }
        its('first.closed') { is_expected.to eq 0 }
        its('second.open') { is_expected.to eq 1 }
        its('second.closed') { is_expected.to eq 1 }
      end
    end

    context 'one issue in first week' do
      let(:issues) { [issue] }
      let(:issue) { stub_issue(created_at: created_at, closed_at: closed_at) }
      let(:created_at) { 1.week.ago.beginning_of_week + 1.second }

      context 'open' do
        let(:closed_at) { nil }

        it { is_expected.to have(2).items }
        its('first.open') { is_expected.to eq 1 }
        its('first.closed') { is_expected.to eq 0 }
        its('second.open') { is_expected.to eq 1 }
        its('second.closed') { is_expected.to eq 0 }
      end

      context 'closed' do
        let(:closed_at) { created_at + 1.second }

        it { is_expected.to have(2).items }
        its('first.open') { is_expected.to eq 1 }
        its('first.closed') { is_expected.to eq 1 }
        its('second.open') { is_expected.to eq 1 }
        its('second.closed') { is_expected.to eq 1 }
      end
    end

    context 'two issue in first week, one closed and one creadte in last', :focus do
      let(:issues) { [issue_1, issue_2, issue_3] }
      let(:issue_1) { stub_issue(created_at: created_at_1, closed_at: closed_at_1) }
      let(:issue_2) { stub_issue(created_at: created_at_2, closed_at: closed_at_2) }
      let(:issue_3) { stub_issue(created_at: created_at_3, closed_at: closed_at_3) }
      let(:created_at_1) { 1.week.ago.beginning_of_week + 1.second }
      let(:created_at_2) { created_at_1 }
      let(:created_at_3) { Time.current.beginning_of_week + 1.second }
      let(:closed_at_1) { nil }
      let(:closed_at_2) { Time.current.beginning_of_week + 2.second }
      let(:closed_at_3) { nil }

      it { is_expected.to have(2).items }
      its('first.open') { is_expected.to eq 2 }
      its('first.closed') { is_expected.to eq 0 }
      its('second.open') { is_expected.to eq 3 }
      its('second.closed') { is_expected.to eq 1 }
    end
  end
end
