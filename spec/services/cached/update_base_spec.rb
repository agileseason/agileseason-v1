describe Cached::UpdateBase do
  let(:cache) { double(write: nil, read: nil) }
  before { allow(Rails).to receive(:cache).and_return(cache) }

  describe '#call' do
    subject { Cached::UpdateBase.call(objects: objects, key: 'foo') }
    let(:objects) { [] }
    let(:now) { Time.current }
    let(:cached_object) { Cached::Item.new(objects, now) }
    before { allow(Cached::Item).to receive(:new).and_return(cached_object) }
    before { Timecop.freeze(now) }
    before { subject }
    after { Timecop.return }

    it do
      expect(cache).
        to have_received(:write).
        with(
          "foo",
          cached_object,
          expires_in: Cached::UpdateBase::READONLY_EXPIRES_IN
        )
    end
  end
end
