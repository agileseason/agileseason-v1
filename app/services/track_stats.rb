class TrackStats
  class << self
    def track(column_ids, hash = nil)
      hash = init_track_hash if hash.blank?
      column_ids = [column_ids] if column_ids.is_a?(Fixnum)
      column_ids.each do |column_id|
        column_data = hash[:track_stats][:columns][column_id.to_s] || in_out_at_hash
        column_data[:out_at] = nil
        hash[:track_stats][:columns][column_id.to_s] = column_data
      end
      fill_out_at(hash, column_ids.last)
      hidden_content(hash)
    end

    def hidden_content(hash)
      "\n<!---\n@agileseason:#{hash.to_json}\n-->"
    end

    def extract(body)
      /(?<comment>.*)\n<!---\s@agileseason:(?<hash>.*)\s-->(?<tail>.*)/im =~ body
      { comment: comment, hash: parse_hash(hash), tail: tail }
    end

    def current_column(hash)
      stats = hash[:track_stats][:columns].detect { |_key, value| value[:out_at].nil? }
      stats.first if stats
    end

    def remove_columns(hash, columns_ids)
      columns_ids.each do |column_id|
        if hash[:track_stats] && hash[:track_stats][:columns]
          hash[:track_stats][:columns].delete(column_id.to_s)
        end
      end
      hash
    end

    private

    def init_track_hash
      { track_stats: { columns: {} } }
    end

    def in_out_at_hash
      { in_at: Time.current.to_s, out_at: nil }
    end

    def parse_hash(json)
      JSON.parse(json).with_indifferent_access
    rescue
      {}
    end

    def fill_out_at(hash, current_column_id)
      hash[:track_stats][:columns].each do |key, value|
        value[:out_at] = Time.current.to_s if key != current_column_id.to_s && value[:out_at].blank?
      end
    end
  end
end
