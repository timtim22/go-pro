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
    Base64.decode64(ENV["GOOGLE_APPLICATION_CREDENTIALS_BASE64"]) if ENV["GOOGLE_APPLICATION_CREDENTIALS_BASE64"]
  end
end
