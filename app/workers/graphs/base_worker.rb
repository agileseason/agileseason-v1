module Graphs
  class BaseWorker
    include Sidekiq::Worker

    def fill_missing_days(entry_histories)
      to_copy = entry_histories.last
      prev_missing_days(entry_histories).each do |missing_date|
        to_copy.dup.update(collected_on: missing_date)
      end
    end

    private

    def prev_missing_days(entry_histories)
      return [] if entry_histories.blank?
      prev_collected_on = entry_histories.last.collected_on
      missing_days = (Date.yesterday - prev_collected_on).to_i
      (1..missing_days).map { |n| Date.today.prev_day(n) }
    end
  end
end
