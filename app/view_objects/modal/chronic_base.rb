module Modal
  class ChronicBase
    attr_reader :id, :user, :created_at, :created_at_str

    def initialize github_object
      @id = github_object.id
      @user = Modal::User.new(fetch_user(github_object))
      @created_at = github_object.created_at
      @created_at_str = fetch_created_at_str(github_object)
    end

    def to_h
      {
        id: id,
        user: user.to_h,
        created_at: created_at,
        created_at_str: created_at_str
      }
    end

    private

    def fetch_user github_object
      github_object.user
    end

    def fetch_created_at_str github_object
      github_object.created_at.to_s
    end
  end
end
