module Unescaper
  def un(url)
    CGI::unescape(url)
  end
end
