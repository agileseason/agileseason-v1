describe MixpanelTracker do
  let(:service) { MixpanelTracker.new }
  let(:token) { 'fake_token' }
  before { allow(service).to receive(:skip?).and_return(false) }
  before { allow(service).to receive(:token).and_return(token) }

  describe '#track_user_event' do
    let(:user) { create(:user, :with_utm) }
    let(:board) { create(:board, :with_columns, user: user) }
    let(:event) { 'event' }
    let(:options) { {} }
    let(:track_user_event) do
      service.track_user_event(user, event, board, options)
    end
    before { allow(MixpanelTrack).to receive(:perform_async) }

    describe 'mixpanel' do
      before { track_user_event }
      it do
        expect(MixpanelTrack).
          to have_received(:perform_async).
          with(token, user.id, event, kind_of(Hash))
      end
    end
  end

  describe '#track_guest_event' do
    let(:guest_id) { 123 }
    let(:event) { 'some event' }
    let(:options) { {} }
    let(:track_guest_event) do
      service.track_guest_event(guest_id, event, options)
    end
    before { allow(MixpanelTrack).to receive :perform_async }

    describe 'mixpanel' do
      before { track_guest_event }

      it do
        expect(MixpanelTrack).
          to have_received(:perform_async).
          with(token, guest_id, event, options)
      end
    end
  end

  describe '#link_user' do
    let(:user) { create :user, :with_utm }
    let(:guest_id) { 123 }
    let(:link_user) { service.link_user(user, guest_id) }
    before { allow(MixpanelLink).to receive :perform_async }

    describe 'mixpanel' do
      before { link_user }
      it do
        expect(MixpanelLink).
          to have_received(:perform_async).
          with(token, user.id, guest_id)
      end
    end
  end

  describe '#set_profile' do
    let(:user) { create :user, :with_utm }
    let(:options) { {} }
    let(:set_profile) { service.set_profile user, options }
    before { allow(MixpanelProfile).to receive(:perform_async) }

    describe 'mixpanel' do
      before { set_profile }

      it do
        expect(MixpanelProfile).
          to have_received(:perform_async).
          with(token, user, options)
      end
    end
  end

  describe '#charge' do
    let(:user) { create :user, :with_utm }
    let(:sum) { 123 }
    let(:charge) { service.charge user, sum }
    before { allow(MixpanelCharge).to receive :perform_async }

    describe 'mixpanel' do
      before { charge }
      it do
        expect(MixpanelCharge).
          to have_received(:perform_async).
          with(token, user, sum)
      end
    end
  end
end
