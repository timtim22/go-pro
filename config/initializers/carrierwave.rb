CarrierWave.configure do |config|
  config.storage = :fog
  config.fog_credentials = {
    config.storage = :fog
    provider: 'Google',
    google_storage_access_key_id: ENV['GOOGLE_STORAGE_ACCESS_KEY_ID'],
    google_storage_secret_access_key: ENV['GOOGLE_STORAGE_SECRET_ACCESS_KEY']
  }
  config.fog_directory = 'slice-app'
  config.fog_public = false
end