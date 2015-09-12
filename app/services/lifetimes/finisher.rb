module Lifetimes
  class Finisher
    pattr_initialize :issue_stat

    def call
      issue_stat.
        lifetimes.
        where(out_at: nil).
        update_all(out_at: Time.current)
    end
  end
end
