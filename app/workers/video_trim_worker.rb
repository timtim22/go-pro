class VideoTrimWorker
  include Sidekiq::Worker
  include CloudStorageHelper

  def perform(video_id, start_time, end_time)
    video = Video.find_by(id: video_id)
    output_path = "#{Rails.root}/tmp/trimmed_#{Time.now.to_i}_#{video.id}.mp4"
    system("ffmpeg -ss #{start_time} -to #{end_time} -i #{video.file.path} -c copy #{output_path}")
    
    if Rails.env.production?
      trimmed_video_file = File.open(output_path)
      file = upload_file_to_cloud_storage(trimmed_video_file)
    else
      file = ActionDispatch::Http::UploadedFile.new(
        tempfile: File.new(output_path),
        filename: video.title,
        type: "mp4"
      )
    end
    slice_video = SliceVideo.create(file: file, video: video, title: video.title)
    VideoTranscriptWorker.perform_async(slice_video.id, 'slice_video')
  end
end
