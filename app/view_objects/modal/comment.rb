module Modal
  class Comment < Modal::ChronicBase
    attr_reader :body, :markdown

    def initialize github_object, markdown
      super github_object
      @body = github_object.body
      @markdown = markdown
    end

    def to_h
      super.merge(type: :comment, body: body, markdown: markdown)
    end

    private

    def fetch_created_at_str github_object
      github_object.created_at.strftime('%b %d, %H:%M')
    end
  end
end
