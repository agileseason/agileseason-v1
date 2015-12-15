describe MixpanelCharge do
  describe '#perform' do
    subject { task.perform('fake_token', user.id, sum) }
    let(:task) { MixpanelCharge.new }
    let(:user) { create :user }
    let(:sum) { 100 }
    let(:tracker) { double(people: people) }
    let(:people) { double(set: nil, track_charge: nil) }
    before { allow(task).to receive(:tracker).and_return tracker }
    before { subject }

    it { expect(people).to have_received(:set) }
    it { expect(people).to have_received(:track_charge).with(user.id, sum) }
  end
end
