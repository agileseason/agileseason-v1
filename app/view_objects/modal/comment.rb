module Modal
  class Comment < Modal::ChronicBase
    attr_reader :body, :bodyMarkdown

    def initialize github_object, bodyMarkdown
      super github_object
      @body = github_object.body
      @bodyMarkdown = bodyMarkdown
    end

    def to_h
      super.merge(type: :comment, body: body, bodyMarkdown: bodyMarkdown)
    end

    private

    def fetch_created_at_str github_object
      github_object.created_at.strftime('%b %d, %H:%M')
    end
  end
end
