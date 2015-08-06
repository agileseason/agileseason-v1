class Subscriber
  EARLY_ACCESS_PERIOD = 3.month

  class << self
    def early_access(board, user)
      if board.subscribed_at.present? && board.subscribed_at >= Time.current
        board.subscriptions.last
      else
        subscribed_at = Time.current + EARLY_ACCESS_PERIOD
        board.update!(subscribed_at: subscribed_at)

        board.subscriptions.create!(
          user: user,
          date_to: subscribed_at,
          cost: 0
        )
      end
    end
  end
end
