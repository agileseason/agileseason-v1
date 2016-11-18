module LinesGraphUpdater
  extend ActiveSupport::Concern

  included do
    after_action :fetch_lines_graph
  end

  def fetch_lines_graph
    Graphs::LinesWorker.perform_async(@board.id, encrypted_github_token)
  end
end
