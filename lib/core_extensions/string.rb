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
    self.first.downcase + self.slice(1..-1)
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
    self.gsub(/\r?\n/, ' ').squeeze("\s").strip
  end

  def punycode
    sub(/\A
      (?<protocol>https?:\/\/)
      (?:
        (?<domain>[^\/:]+)
        (?<port>:\d+)
        |
        (?<domain>[^\/]+)
      )
      (?<path>.*)
    \Z/x) do
      $~[:protocol] + SimpleIDN.to_ascii($~[:domain]) + ($~[:port] || '') + $~[:path]
    end
  end

  def depunycode
    segments = (self[-1] == '/' ? "#{self} " : self).split('/')
    domain_index = self.has_protocol? ? 2 : 0

    segments[domain_index] = if segments[domain_index].include?(':')
      # ситуация домена с портом
      parts = segments[domain_index].split(':')
      parts[0] = parts[0].depunycode
      parts.join(':')
    else
      SimpleIDN.to_unicode segments[domain_index]
    end

    segments.join('/').strip
  rescue RangeError
    self
  end

  def has_protocol?
    self.starts_with?('https://') || self.starts_with?('http://')
  end
end
