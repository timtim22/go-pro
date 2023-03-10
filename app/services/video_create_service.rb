class VideoCreateService

  def initialize(file, current_user)
    @file = file
    @current_user = current_user
  end

  def call
    if Rails.env.production?
      file_url = upload_file_to_cloud_storage(@file)
      VideoProcessWorker.perform_async(file_url, @current_user.id, nil)
    else
      tempfile = @file.tempfile
      new_tempfile_path = Rails.root.join('tmp', "#{Time.now.to_i}_#{@file.original_filename}")
      FileUtils.mkdir_p(File.dirname(new_tempfile_path))
      FileUtils.touch(new_tempfile_path)
      FileUtils.cp(tempfile.path, new_tempfile_path)
      VideoProcessWorker.perform_async(new_tempfile_path.to_s, @current_user.id, JSON.parse(@file.to_json))
    end
  end

  private

  def upload_file_to_cloud_storage(file)
    storage = Google::Cloud::Storage.new(
      project_id: ENV['PROJECT_ID'],
      credentials: ENV['GOOGLE_APPLICATION_CREDENTIALS']
    )
    bucket = storage.bucket(ENV['BUCKET_NAME'])
    file_path = "uploads/#{SecureRandom.uuid}_#{file.original_filename}"
    bucket.create_file(file.path, file_path)
    bucket.file(file_path).signed_url(method: 'GET', expires: 1.hour.from_now.to_i)
  end
end
