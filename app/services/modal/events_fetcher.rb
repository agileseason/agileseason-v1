module Modal
  class EventsFetcher
    include VirtusService

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :number, Integer

    def call
      return [] unless issue.present?
      return events unless more_events?

      events + github_events
    end

    private

    def events
      @events ||= [opened_event]
    end

    def issue
      @issue ||= board_bag.issue(number).try(:issue)
    end

    def more_events?
      issue.state == 'closed' || issue.closed_by
    end

    def opened_event
      Modal::Event.new(OpenStruct.new(
        id: 1,
        event: 'opened_fake',
        actor: issue.user,
        created_at: issue.created_at
      ))
    end

    def github_events
      @github_events ||= Cached::Events.
        call(user: user, board: board_bag.board, number: number).
        map { |event| Modal::Event.new(event) }
    end
  end
end
