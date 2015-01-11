describe IssuePresenter do
  let(:presenter) { present(:issue, issue) }
  let(:issue) { OpenStruct.new(labels: [label]) }
  let(:label) { OpenStruct.new(name: 'bug', color: color) }

  describe '#color' do
    subject { presenter.color(label) }

    context 'red' do
      let(:color) { 'fc2929' }
      it { is_expected.to eq 'fff' }
    end

    context 'white' do
      let(:color) { 'ffffff' }
      it { is_expected.to eq '000' }
    end

    context 'dark blue' do
      let(:color) { '5319e7' }
      it { is_expected.to eq 'fff' }
    end

    context 'blue' do
      let(:color) { '84b6eb' }
      it { is_expected.to eq '000' }
    end
  end
end
