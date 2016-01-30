module Modal
  class User
    attr_reader :id, :login, :avatar_url

    def initialize github_object
      @id = github_object.id
      @login = github_object.login
      @avatar_url = github_object.avatar_url
    end

    def to_h
      {
        id: id,
        login: login,
        avatar_url: avatar_url
      }
    end
  end
end
