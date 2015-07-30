class MixpanelProfile < MixpanelTrack
  def perform(token, user, options)
    tracker(token).people.set(user.id, options)
  end
end
