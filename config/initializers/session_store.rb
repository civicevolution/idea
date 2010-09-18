# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_ce1_session',
  :secret      => '131746041b2fba68cb0d10eb6628113f98e6b2745bc08606c0492208259366f5dff2553d4d94a2e9bdb0577b8ffac9a5b6230814d80e245629fef3da326c3e99'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
