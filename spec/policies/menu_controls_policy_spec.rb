describe MenuControlsPolicy do
  describe '#visible?' do
    subject { policy.visible? }
    let(:policy) { MenuControlsPolicy.new(controller) }

    context 'true' do
      let(:controller) { BoardsController.new }
      it { is_expected.to eq true }
    end

    context 'false' do
      let(:controller) { SettingsController.new }
      it { is_expected.to eq false }
    end
  end
end
