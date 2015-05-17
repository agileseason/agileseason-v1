describe ColumnPresenter do
  let(:presenter) { ColumnPresenter.new(:column, column) }
  let(:column) { build(:column, wip_min: min, wip_max: max, issue_stats: issues) }
  let(:issues) { [] }

  describe '#wip_status' do
    subject { presenter.wip_status }
    let(:min) { nil }
    let(:max) { nil }

    context 'normal' do
      context 'not set any limits' do
        it { is_expected.to eq :normal }
      end

      context 'less than max' do
        let(:issues) { [IssueStat.new] }

        context 'min nil' do
          let(:max) { 2 }
          it { is_expected.to eq :normal }
        end

        context 'min not nil' do
          let(:min) { 1 }
          let(:max) { 2 }
          it { is_expected.to eq :normal }
        end
      end

      context 'eq max' do
        let(:max) { 1 }
        let(:issues) { [IssueStat.new] }
        it { is_expected.to eq :normal }
      end
    end

    context 'warning' do
      let(:issues) { [IssueStat.new] }

      context 'less than min' do
        let(:min) { 2 }

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
      let(:issues) { [IssueStat.new, IssueStat.new] }

      context 'greate than max' do
        let(:max) { 1 }

        context 'min nil' do
          let(:min) {}
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
