class GithubApi
  module Comments
    def issue_comments(board, number)
      client.issue_comments(board, number).reverse
    end
  end
end
