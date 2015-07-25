describe MixpanelTrack do
  describe '#perform' do
    let(:user_id) { 123 }
    let(:event) { 'some event' }
    let(:options) { { zzz: true } }

    let(:worker) { MixpanelTrack.new }
    let(:tracker) { worker.send :tracker }

    before { allow(tracker).to receive :track }
    before { allow(worker).to receive(:can_track?).and_return(true) }
    before { worker.perform(user_id, event, options) }

    it do
      expect(tracker).
        to have_received(:track).
        with(user_id, event, options)
    end
  end
end
