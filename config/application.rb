require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require File.expand_path('../../lib/core_extensions/string', __FILE__)
require File.expand_path('../../lib/time_with_timezone', __FILE__)

module Agileseason
  DOMAIN = Rails.env.production? ? 'https://agileseason.com' : 'http://agileseason.dev'
  SUPPORT_EMAIL = 'support@agileseason.com'
  SUPPORT_CHAT = 'https://gitter.im/agileseason/agileseason'

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += Dir["#{config.root}/app/**/"]

    config.paths.add 'lib', eager_load: true

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    routes.default_url_options[:host] = DOMAIN

    config.generators do |g|
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.helper false
      g.helper_specs false
      g.stylesheets false
      g.javascripts false
      g.template_engine :slim
      g.test_framework :rspec
      g.view_specs false
    end
  end
end
