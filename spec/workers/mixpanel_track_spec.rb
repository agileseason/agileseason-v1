describe MixpanelTrack do
  describe '#perform' do
    let(:user_id) { 123 }
    let(:event) { 'some event' }
    let(:options) { { zzz: true } }
    let(:token) { 'fake_token' }

    let(:worker) { MixpanelTrack.new }
    let(:tracker) { worker.send(:tracker, token) }

    before { allow(tracker).to receive :track }
    before { worker.perform(token, user_id, event, options) }

    it do
      expect(tracker).
        to have_received(:track).
        with(user_id, event, options)
    end
  end
end
