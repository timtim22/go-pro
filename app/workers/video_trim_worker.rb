class VideoTrimWorker
  include Sidekiq::Worker

  def perform(video_id, start_time, end_time)
    video = Video.find_by(id: video_id)
    if Rails.env.production?
      storage = Google::Cloud::Storage.new(
        project_id: ENV['PROJECT_ID'],
        credentials: ENV['GOOGLE_APPLICATION_CREDENTIALS']
      )
      bucket = storage.bucket(ENV['BUCKET_NAME'])
      bucket_file = bucket.file(video.file.path)
      current_file_path = File.join(Rails.root, "tmp", "#{SecureRandom.uuid}_#{video.id}")
      output_file_path = File.join(Rails.root, "tmp", "trimmed_#{SecureRandom.uuid}_#{video.id}.mp4")
      bucket_file.download(current_file_path)
      `ffmpeg -i #{current_file_path} -ss #{start_time} -t #{end_time} -async 1 #{output_file_path}`

      file = URI.open(output_file_path)
    else
      file = ActionDispatch::Http::UploadedFile.new(
        tempfile: File.new(output_path),
        filename: video.title,
        type: 'mp4'
      )
    end
    slice_video = SliceVideo.create(file: file, video: video, title: video.title)
    VideoTranscriptWorker.perform_async(slice_video.id, 'slice_video')
    if Rails.env.production?
      File.delete current_file_path
      File.delete output_file_path
    end
  end
end
