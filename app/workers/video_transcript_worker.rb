class VideoTranscriptWorker
  include Sidekiq::Worker

  def perform(video_id)
    video = Video.find_by(id: video_id)
    speech = Google::Cloud::Speech.speech
    video_url = Rails.env.production? ? video.file.url : video.file.current_path
    movie = FFMPEG::Movie.new(video_url)
    video_flac = Tempfile.new(["audio", ".flac"])
    movie.transcode(video_flac.path, {audio_codec: "flac"})
    video_file = File.binread video_flac
    video_content      = { content: video_file }

    config = { 
      encoding:          "FLAC",
      audio_channel_count: 2,
      sample_rate_hertz: 44100,
      language_code:     "en-US",
      enable_word_time_offsets: true
    }

    operation = speech.long_running_recognize config: config, audio: video_content
    operation.wait_until_done!
    results = operation.response.results

    words_hash = {}
    results.each do |word|
      word.alternatives.first.words.each do |word|
        if words_hash.has_key?(word)
          words_hash[word.word] << word.start_time.seconds
        else
          words_hash[word.word] = [word.start_time.seconds]
        end
      end
    end

    transcript = Transcript.new(transcript: words_hash, video: video )
    transcript.save
    video_flac.close
    video_flac.unlink
  end
end