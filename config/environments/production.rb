Aapaurmain::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true
  config.assets.css_compressor = :yui
  config.assets.js_compressor = :yui

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += [ 'active_admin.css', 'active_admin/print.css', 'active_admin.js', '*.js', '*.css' ]
  # %w( application-search.js application-all.js application-conversation.js application-user.js application-all.css application-search.css application-user.css )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  config.action_mailer.delivery_method = :smtp
  
  config.action_mailer.smtp_settings = {
    :address              => "smtp.sendgrid.net",
    :port                 => 587,
    :domain               => 'aapaurmain.com',
    :user_name            => 'aapaurmain',
    :password             => '1lovem4w0rk',
    :authentication       => 'plain',
    :enable_starttls_auto => true  }

  config.action_mailer.default_url_options = { :host => "aapaurmain.com" }

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  $aapaurmain_conf = YAML.load(File.read("#{Rails.root}/config/globals.yml"))

  $search_conf = YAML.load(File.read("#{Rails.root}/config/search.yml"))
  $user_tips = YAML.load(File.read("#{Rails.root}/config/user_tips.yml"))
  $priorities_list = YAML.load(File.read("#{Rails.root}/config/priorities_list.yml"))
    
  require "pusher"
  Pusher.app_id = $aapaurmain_conf['pusher']['app_id']
  Pusher.key    = $aapaurmain_conf['pusher']['key']
  Pusher.secret = $aapaurmain_conf['pusher']['secret']

end
