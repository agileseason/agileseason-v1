class ActiveSupport::TimeWithZone
  def to_js
    to_date.to_datetime.utc.to_i * 1000
  end
end
