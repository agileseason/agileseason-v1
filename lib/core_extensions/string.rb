class String
  def upcase
    Unicode.upcase self
  end

  def downcase
    Unicode.downcase self
  end

  def capitalize
    Unicode.capitalize self
  end

  def uncapitalize
    first.downcase + slice(1..-1)
  end

  def with_http
    sub %r{\A(?!https?://)}, 'http://'
  end

  def without_http
    sub %r{\A(?:https?:)?//}, ''
  end

  def extract_domain
    without_http.sub(%r{/.*}, '')
  end

  def extract_path
    without_http.sub(%r{\A[^/]*}, '').sub(/\A\Z/, '/')
  end

  def prettify
    gsub(/\r?\n/, ' ').squeeze("\s").strip
  end

  def has_protocol?
    starts_with?('https://') || starts_with?('http://')
  end
end
