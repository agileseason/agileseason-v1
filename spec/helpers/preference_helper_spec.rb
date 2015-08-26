describe PreferenceHelper do
  describe '.rolling_average_window' do
    subject { helper.rolling_average_window }

    context 'default' do
      it { is_expected.to eq PreferenceHelper::DEFAULT_ROLLING_AVERAGE_WINDOW }
    end

    context 'user preference' do
      before { helper.rolling_average_window = 11 }
      it { is_expected.to eq 11 }
    end
  end
end
