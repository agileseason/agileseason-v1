class GithubApi
  module Comments
    def issue_comments(repo, number)
      comments = []
      client.issue_comments(repo, number).reverse.each do |comment|
        comments << comment
      end
      comments
    end
  end
end
