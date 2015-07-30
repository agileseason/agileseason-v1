class MixpanelTrack
  include Sidekiq::Worker
  sidekiq_options queue: :mixpanel

  def perform(token, user_id, event, options)
    tracker(token).track(user_id, event, options)
  end

  private

  def tracker(token)
    @tracker ||= Mixpanel::Tracker.new(token)
  end
end
