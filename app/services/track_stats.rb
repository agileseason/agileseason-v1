class TrackStats
  class << self
    def track(column_id, hash = init_track_hash)
      hash[:track_stats][:columns].each do |_key, value|
        value[:out_at] = Time.current.to_s unless value[:out_at]
      end

      hash[:track_stats][:columns][column_id] = {
        in_at: Time.current.to_s,
        out_at: nil
      }
      hidden_content(hash)
    end

    def hidden_content(hash)
      "\n<!---\n@agileseason:#{hash}\n-->"
    end

    private

    def init_track_hash
      { track_stats: { columns: { } } }
    end
  end
end
