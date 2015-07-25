describe MixpanelLink do
  describe '#perform' do
    let(:user) { create :user, :with_utm }
    let(:guest_id) { 123 }

    let(:worker) { MixpanelLink.new }
    let(:tracker) { worker.send :tracker }
    let(:people) { double set: nil }

    before { allow(tracker).to receive :alias }
    before { allow(tracker).to receive(:people).and_return people }
    before { allow(worker).to receive(:can_track?).and_return(true) }
    before { worker.perform(user.id, guest_id) }

    it do
      expect(tracker).
        to have_received(:alias).
        with(user.id, guest_id)
    end

    it do
      expect(people).
        to have_received(:set).
        with(user.id, kind_of(Hash))
    end
  end
end
