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

  #describe '#current_column?' do
    #let(:label1) { OpenStruct.new(name: 'bug') }
    #let(:label2) { OpenStruct.new(name: '[1] Backlog') }

    #let(:labels) { [label1, labael2] }

    #let(:current_column_name) { 'Backlog' }

    #it { is_expected.to be_true }
  #end
end
