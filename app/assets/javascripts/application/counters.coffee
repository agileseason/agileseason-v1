# Turbolinks and mentrika.yandex.ru, google.analytics
$(document).on 'page:before-change', =>
  @turbolinks_referer = location.href

$(document).on 'page:load', =>
  if @turbolinks_referer
    if @yaCounter27976815
      @yaCounter27976815.hit location.href, $('title').html(), @turbolinks_referer
    if @ga
      @ga 'send', 'pageview'
