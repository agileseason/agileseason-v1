class MixpanelCharge < MixpanelTrack
  def perform(user_id, sum)
    return unless can_track?
    user = User.find(user_id)
    tracker.people.set(user_id, profile_parameters(user))
    tracker.people.track_charge(user_id, sum)
  end

private

  def profile_parameters(user)
    parameters = {
      last_buy_at: Time.zone.now,
      total_purchase: 0, # TODO Count subcriptions.
      total_spent: 0 # TODO Sum subsriptions.
    }
    parameters[:first_buy_at] = Time.zone.now # TODO if is first subscription.
    parameters
  end
end
