#= require jquery
#= require jquery-ui
#= require jquery-ui/datepicker
#= require jquery_ujs

# ---  For clientside timezone  ---
#= require jquery.cookie
#= require jstz
#= require browser_timezone_rails/set_time_zone

#= require jquery.elastic.source
#= require highcharts.js
#= require replace_nth_match.js
#= require js-patch.coffee
#= require turbolinks
#= require_tree .

# ---  Fileupload loaded after all  ---
#= require vendor/jquery.fileupload
#= require jquery.scrollTo

# Turbolinks and mentrika.yandex.ru
$(document).on 'page:before-change', =>
  @turbolinks_referer = location.href
$(document).on 'page:load', =>
  if @turbolinks_referer
    if @yaCounter27976815
      @yaCounter27976815.hit location.href, $('title').html(), @turbolinks_referer
