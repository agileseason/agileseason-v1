class GithubApi
  module Comments
    def issue_comments(board, number)
      client.issue_comments(board.github_id, number).reverse
    end

    def add_comment(board, number, comment)
      client.add_comment(board.github_id, number, comment)
    end

    def update_comment(board, number, comment)
      client.update_comment(board.github_id, number, comment)
    end

    #def add_comment(options)
      #client.create_pull_request_comment(
        #options[:commit].repo_name,
        #options[:pull_request_number],
        #options[:comment],
        #options[:commit].sha,
        #options[:filename],
        #options[:patch_position]
      #)
    #end
  end
end
