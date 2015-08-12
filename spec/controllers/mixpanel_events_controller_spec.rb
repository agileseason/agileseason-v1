RSpec.describe MixpanelEventsController, type: :controller do
  describe '#client_event' do
    before { allow(controller).to receive(:ui_event) }
    before { post :client_event, event: event }

    context 'valid event' do
      let(:event) { 'landing' }
      it { expect(controller).to have_received(:ui_event) }
    end

    context 'invalid event' do
      let(:event) { 'fake' }
      it { expect(controller).not_to have_received(:ui_event) }
    end
  end
end
