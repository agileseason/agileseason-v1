SidekiqUniqueJobs.config.unique_args_enabled = true

module Sidekiq
  UNIQUE_OPTIONS = { unique: true, unique_args: -> (args) { Digest::MD5.hexdigest args.to_json } }
end
