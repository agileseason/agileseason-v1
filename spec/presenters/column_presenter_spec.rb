describe ColumnPresenter do
  let(:presenter) { ColumnPresenter.new(:column, column) }
  let(:column) { build(:column, settings: settings, issues: issues) }
  let(:issues) { [] }

  describe '#wip_status' do
    subject { presenter.wip_status }

    context 'normal' do
      context 'not set any limits' do
        let(:settings) { nil }
        it { is_expected.to eq :normal }
      end

      context 'less than max' do
        let(:settings) { WipColumnSettings.new(min: min, max: max) }
        let(:issues) { [OpenStruct.new] }

        context 'min nil' do
          let(:min) { nil }
          let(:max) { 2 }
          it { is_expected.to eq :normal }
        end

        context 'min not nil' do
          let(:min) { 1 }
          let(:max) { 2 }
          it { is_expected.to eq :normal }
        end
      end
    end

    context 'warning' do
      let(:issues) { [OpenStruct.new] }

      context 'less than min' do
        let(:settings) { { min: 2, max: max } }

        context 'max nil' do
          let(:max) { }
          it { is_expected.to eq :warning }
        end

        context 'max not nil' do
          let(:max) { 3 }
          it { is_expected.to eq :warning }
        end
      end
    end

    context 'alert' do
      let(:issues) { [OpenStruct.new, OpenStruct.new] }

      context 'greate than max' do
        let(:settings) { { min: min, max: 1 } }

        context 'min nil' do
          let(:min) { }
          it { is_expected.to eq :alert }
        end

        context 'min not nil' do
          let(:min) { 1 }
          it { is_expected.to eq :alert }
        end
      end
    end
  end
end
