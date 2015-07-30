class MixpanelTrack
  include Sidekiq::Worker
  sidekiq_options queue: :mixpanel

  def perform(user_id, event, options)
    tracker.track(user_id, event, options)
  end

  private

  def tracker
    logger.info '********************************'
    logger.info "* TOKEN = #{token} *"
    logger.info '********************************'
    raise 'Error token' if token.blank? && !Rails.env.test?
    @tracker ||= Mixpanel::Tracker.new(token)
  end

  def token
    ENV['AGILE_SEASON_MIXPANEL_TOKEN'] || Agileseason::MIXPANEL_TOKEN
  end
end
