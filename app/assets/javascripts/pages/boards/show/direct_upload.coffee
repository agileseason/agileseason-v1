window.build_s3_image_url = (url, key) ->
  sanitize_key = encodeURIComponent(key)
  sanitize_key = sanitize_key.replace(/([(){}\[\]#+-.!])/g, "\\$1")
  "![#{key}](#{url}/#{sanitize_key})"
