module CumulativeGraphUpdater
  extend ActiveSupport::Concern

  included do
    after_action :fetch_cumulative_graph
  end

  def fetch_cumulative_graph
    Graphs::CumulativeWorker.perform_async(@board.id, encrypted_github_token)
  end
end
