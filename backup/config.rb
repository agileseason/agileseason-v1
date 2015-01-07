##
# Backup v4.x Configuration
#
# Documentation: http://meskyanichi.github.io/backup
# Issue Tracker: https://github.com/meskyanichi/backup/issues

require 'yaml'
require 'dotenv'

# Get our environment variables
Dotenv.load

# Get the current Rails Environment, otherwise default to development
RAILS_ENV = ENV['RAILS_ENV'] || 'development'

# Load database.yml, including parsing any ERB it might
# contain. Remember if you're using Mongo, this should be
# mongoid.yml
DB_CONFIG = YAML.load(ERB.new(File.read(File.expand_path('../../config/database.yml',  __FILE__))).result)[RAILS_ENV]
