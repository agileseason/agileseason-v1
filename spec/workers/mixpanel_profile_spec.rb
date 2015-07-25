describe MixpanelProfile do
  describe '#perform' do
    let(:user) { build :user }
    let(:options) { { zzz: true } }

    let(:worker) { MixpanelProfile.new }
    let(:tracker) { worker.send :tracker }
    let(:people) { double set: nil }

    before { allow(tracker).to receive(:people).and_return people }
    before { allow(worker).to receive(:can_track?).and_return(true) }
    before { worker.perform(user, options) }

    it do
      expect(people).
        to have_received(:set).
        with(user.id, options)
    end
  end
end
