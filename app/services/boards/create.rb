module Boards
  class Create
    include Service
    include Virtus.model

    attribute :user, User
    attribute :board_params, Hash
    attribute :columns_params, Hash
    attribute :encrypted_github_token, String

    def call
      board.columns << build_columns
      return board unless board.valid?

      board.save
      WebhookWorker.perform_async(board.id, encrypted_github_token)
      Graphs::IssueStatsWorker.new.perform(board.id, encrypted_github_token)

      board
    end

  private

    def board
      @board ||= user.boards.build(board_params)
    end

    def build_columns
      columns_params[:name].select(&:present?).each_with_index.map do |name, index|
        Column.new(name: name, order: index + 1, board: board)
      end
    end
  end
end
