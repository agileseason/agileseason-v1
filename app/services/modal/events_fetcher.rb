module Modal
  class EventsFetcher
    include VirtusService

    attribute :user, User
    attribute :board_bag, BoardBag
    attribute :number, Integer

    def call
      return [] unless issue.present?
      # FIX Remove defined? after removing Sawyer::Resource from cache.
      # HOTFIX https://agileseason.com/boards/agileseason/agileseason?number=831
      events << opened_event if defined?(issue.user.id) || issue.user[:id]
      return events unless more_events?

      events + github_events
    end

    private

    def events
      @events ||= []
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
