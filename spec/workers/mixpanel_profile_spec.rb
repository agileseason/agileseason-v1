describe MixpanelProfile do
  describe '#perform' do
    let(:user) { build :user }
    let(:options) { { zzz: true } }
    let(:token) { 'fake_token' }

    let(:worker) { MixpanelProfile.new }
    let(:tracker) { worker.send(:tracker, token) }
    let(:people) { double set: nil }

    before do
      allow(tracker).
        to receive(:people).
        and_return(people)
    end
    before { worker.perform(token, user, options) }

    it do
      expect(people).
        to have_received(:set).
        with(user.id, options)
    end
  end
end
