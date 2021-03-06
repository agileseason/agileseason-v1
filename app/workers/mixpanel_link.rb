class MixpanelLink < MixpanelTrack
  def perform(token, user_id, guest_id)
    user = User.find(user_id)
    tracker(token).alias(user_id, guest_id)
    tracker(token).people.set(user.id, options(user))
  end

  private

  def options user
    {
      '$email' => user.email,
      '$github_username' => user.github_username,
      '$created' => user.created_at.to_date,
      source: user.utm['source'],
      campaign: user.utm['campaign'],
      medium: user.utm['medium'],
      total_purchase: 0,
      total_spent: 0
    }
  end
end
