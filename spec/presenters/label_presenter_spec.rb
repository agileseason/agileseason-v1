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

    context 'github lighth colors' do
      LabelPresenter::GITHUB_LIGHT_COLORS.each do |color|
        context "#{color}" do
          let(:color) { color }
          it { is_expected.to eq '000' }
        end
      end
    end
  end
end
