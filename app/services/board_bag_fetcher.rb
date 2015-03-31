class BoardBagFetcher < BoardBag
  pattr_initialize :github_api, :board

  def refresh_collaborators
    Rails.cache.write(cache_key(:collaborators), @github_api.collaborators(@board), expires_in: 20.minutes)
  end

  def refresh_labels
    Rails.cache.write(cache_key(:labels), @github_api.labels(@board), expires_in: 20.minutes)
  end

  def refresh_issues
    Rails.cache.write(cache_key(:board_issues), @github_api.board_issues(@board), expires_in: 5.minutes)
  end
end
