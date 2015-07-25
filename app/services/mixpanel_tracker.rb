class MixpanelTracker
  def track_user_event(user, event, board = nil, options = {})
    return if skip?

    options.merge!(user_event_options(user, board))
    MixpanelTrack.perform_async(user.id, event.to_s, options)
  end

  def track_guest_event(guest_id, event, options = {})
    return if skip?
    MixpanelTrack.perform_async(guest_id, event.to_s, options)
  end

  def link_user(user, guest_id)
    return if skip?
    MixpanelLink.perform_async(user.id, guest_id)
  end

  def set_profile(user, options)
    return if skip?
    MixpanelProfile.perform_async(user, options)
  end

  def charge(user, sum)
    return if skip?
    MixpanelCharge.perform_async user, sum
  end

  private

  def skip?
    Rails.env.test?
  end

  def user_event_options(user, board)
    {
      email: user.email,
      github_username: user.github_username,
      user_created: user.created_at.to_date.to_s,
      board_id: board.try(:id),
      source: user.utm['source'],
      campaign: user.utm['campaign'],
      medium: user.utm['medium'],
    }
  end
end
