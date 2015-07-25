class MixpanelProfile < MixpanelTrack
  def perform(user, options)
    return unless can_track?
    tracker.people.set(user.id, options)
  end
end
