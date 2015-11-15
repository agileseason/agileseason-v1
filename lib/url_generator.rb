class UrlGenerator
  class << self
    include Rails.application.routes.url_helpers
  end
end
