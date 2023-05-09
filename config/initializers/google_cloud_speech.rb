require "base64"
require "google/cloud/speech"

if ENV["GOOGLE_APPLICATION_CREDENTIALS_BASE64"]
  json_credentials = Base64.decode64(ENV["GOOGLE_APPLICATION_CREDENTIALS_BASE64"])
  tempfile = Tempfile.new(["service_account", ".json"])
  tempfile.write(json_credentials)
  tempfile.rewind
  at_exit do
    tempfile.close
    tempfile.unlink
  end
  Google::Cloud::Speech.configure do |config|
    config.credentials = tempfile.path
  end
end
