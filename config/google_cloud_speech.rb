require "base64"
require "google/cloud/speech"

if ENV["GOOGLE_APPLICATION_CREDENTIALS_BASE64"]
  json_credentials = Base64.decode64(ENV["GOOGLE_APPLICATION_CREDENTIALS_BASE64"])

  # Create a temporary JSON file with the decoded credentials
  tempfile = Tempfile.new(["service_account", ".json"])
  tempfile.write(json_credentials)
  tempfile.rewind

  # Save the tempfile reference as an at_exit hook to avoid its deletion while the app is running
  at_exit do
    tempfile.close
    tempfile.unlink
  end

  Google::Cloud::Speech.configure do |config|
    # Pass the file path to the configuration
    config.credentials = tempfile.path
  end
end
