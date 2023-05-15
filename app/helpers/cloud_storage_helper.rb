module CloudStorageHelper
  def upload_file_to_cloud_storage(file)
    storage = Google::Cloud::Storage.new(
      project_id: ENV['PROJECT_ID'],
      credentials: decoded_google_credentials
    )
    bucket = storage.bucket(ENV['BUCKET_NAME'])
    file_path = "uploads/#{SecureRandom.uuid}_#{file.original_filename}"
    bucket.create_file(file.path, file_path)
    bucket.file(file_path).signed_url(method: 'GET', expires: 1.hour.from_now.to_i)
  end

  def decoded_google_credentials
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
  
      tempfile.path
    end
  end
end
