class GithubApi
  module Comments
    def get_comments(repo, number)
      client.issue_comments(repo, number).reverse.each do |comment|
        username = comment[:user][:login]
        post_date = comment[:created_at]
        content = comment[:body]

        puts "#{username} made a comment on #{post_date}. It says:\n'#{content}'\n"
      end
    end
  end
end
