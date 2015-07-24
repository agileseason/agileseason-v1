describe LabelPresenter do
  let(:presenter) { present(:label, label) }

  describe '#font_color' do
    subject { presenter.font_color }
    let(:label) { OpenStruct.new(name: 'bug', color: color) }

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
