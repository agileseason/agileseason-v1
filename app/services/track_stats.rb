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
      "\n<!---\n@agileseason:#{hash.to_json}\n-->"
    end

    def extract(body)
      /(.*)\n<!---\s@agileseason:(.*)\s-->(.*)/im =~ body
      { comment: $1, hash: JSON.parse($2).with_indifferent_access, end: $3 }
    end

    private

    def init_track_hash
      { track_stats: { columns: {} } }
    end
  end
end
