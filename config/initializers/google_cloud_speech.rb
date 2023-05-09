require "base64"
require "google/cloud/speech"

if ENV["GOOGLE_APPLICATION_CREDENTIALS_BASE64"]
  json_credentials = Base64.decode64(ENV["GOOGLE_APPLICATION_CREDENTIALS_BASE64"])
  Google::Cloud::Speech.configure do |config|
    config.credentials = json_credentials
  end
end
