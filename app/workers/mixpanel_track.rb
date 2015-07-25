class MixpanelTrack
  include Sidekiq::Worker
  sidekiq_options queue: :mixpanel

  def perform(user_id, event, options)
    return unless can_track?
    tracker.track(user_id, event, options)
  end

private

  def tracker
    @tracker ||= Mixpanel::Tracker.new(token)
  end

  def token
    ENV['AGILE_SEASON_MIXPANEL_TOKEN']
  end
end
