# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'https://agileseason.com'

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  add(board_features_docs_path, lastmod: Time.new(2015, 11, 28))
  add(cumulative_docs_path, lastmod: Time.new(2015, 9, 17))
  add(control_docs_path, lastmod: Time.new(2015, 9, 17))
  add(age_docs_path, lastmod: Time.new(2016, 3, 27))
end
