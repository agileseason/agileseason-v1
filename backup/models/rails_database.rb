##
# Backup Generated: rails_database
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t rails_database [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://meskyanichi.github.io/backup
#
Model.new(:rails_database, 'Backups of the Rails Database') do
  case ENV['BACKUP_ENV']
  when 'development'
    ##
    # SQLite [Database] - Development
    #
    database SQLite do |db|
      db.name               = 'development.sqlite3'
      # Path to database
      db.path               = '/Users/slash/projects/agileseason/db/'
      # Optional: Use to set the location of this utility
      #   if it cannot be found by name in your $PATH
      db.sqlitedump_utility = '/usr/bin/sqlite3'
    end
  else
    ##
    # PostgreSQL [Database]
    #
    database PostgreSQL do |db|
      db.name               = DB_CONFIG['database']
      db.username           = DB_CONFIG['username']
      db.password           = DB_CONFIG['password']
      db.host               = DB_CONFIG['host']
      db.skip_tables        = []
      db.socket             = DB_CONFIG['socket']
      db.additional_options = ['-xc', '-E=utf8']
    end
  end

  store_with Dropbox do |db|
    db.api_key     = ENV['BACKUP_DROPBOX_API_KEY']
    db.api_secret  = ENV['BACKUP_DROPBOX_API_SECRET']
    # Sets the path where the cached authorized session will be stored.
    # Relative paths will be relative to ~/Backup, unless the --root-path
    # is set on the command line or within your configuration file.
    db.cache_path  = '.cache'
    # :app_folder (default) or :dropbox
    db.access_type = :app_folder
    db.path        = '/backups/agileseason'
    db.keep        = 25
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip
end
