describe MenuPolicy do
  describe '#visible?' do
    subject { policy.visible? }
    let(:policy) { MenuPolicy.new(controller, board) }
    let(:board) { nil }

    context 'true' do
      describe 'some another controller' do
        let(:controller) { SettingsController.new }
        it { is_expected.to eq true }
      end

      describe 'boards controller' do
        let(:controller) { BoardsController.new }

        context 'board is not broken' do
          before { allow(controller).to receive(:action_name).and_return('show') }
          let(:board) { build_stubbed :board }
          it { is_expected.to eq true }
        end
      end
    end

    context 'false' do
      describe 'docs controller' do
        let(:controller) { DocsController.new }
        it { is_expected.to eq false }
      end

      describe 'boards controller' do
        let(:controller) { BoardsController.new }

        context 'action_name is show and board is not persisted' do
          before { allow(controller).to receive(:action_name).and_return('show') }
          let(:board) { build :board }
          it { is_expected.to eq false }
        end
      end
    end
  end
end
