module Lifetimes
  class Starter
    pattr_initialize :issue_stat, :column

    def call
      issue_stat.lifetimes.create!(column: column, in_at: Time.current)
    end
  end
end
