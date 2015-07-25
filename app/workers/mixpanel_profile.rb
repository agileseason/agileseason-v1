class MixpanelProfile < MixpanelTrack
  def perform(user, options)
    tracker.people.set(user.id, options)
  end
end
