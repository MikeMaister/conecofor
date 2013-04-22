# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_conecofor_session',
  :secret      => '32edf4fa593c9d30e963028e32b87a8b383ebf242a349ebc0d2843e525118295da6fceaa803f36abc3100bc809106cf4a7d69f8bf2475aa0573856337ad79e3a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
