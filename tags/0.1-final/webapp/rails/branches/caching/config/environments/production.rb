# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new
config.log_level = :error

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
if CACHED
  if MEMCACHED
    config.action_controller.cache_store = :mem_cache_store, CACHE_SERVER
  else
    config.action_mailer.raise_delivery_errors = false
    config.action_controller.cache_store = :file_store, RAILS_ROOT + '/tmp/cache/'
  end
end
