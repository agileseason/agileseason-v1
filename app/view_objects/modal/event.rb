module Modal
  class Event < Modal::ChronicBase
    include ActionView::Helpers::DateHelper

    attr_reader :text, :type

    def initialize github_object
      super github_object
      @text = fetch_text(github_object)
    end

    def to_h
      super.merge(type: :event, text: text)
    end

    private

    def fetch_text github_object
      case github_object.event
      when 'opened_fake'
        "opened this issue #{time_ago_in_words(created_at)} ago"

      when 'closed'
        "closed this #{time_ago_in_words(created_at)} ago"

      when 'reopened'
        "reopened this #{time_ago_in_words(created_at)} ago"

      else
        "event #{time_ago_in_words(created_at)} ago"
      end
    end

    def fetch_user github_object
      github_object.actor
    end
  end
end
