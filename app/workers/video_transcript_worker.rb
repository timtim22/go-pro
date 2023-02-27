class VideoTranscriptWorker
  include Sidekiq::Worker
  include VideoTranscriptConfigHelper

  def perform(video_id)
    video         = Video.find_by(id: video_id)
    speech        = Google::Cloud::Speech.speech
    video_path    = Rails.env.production? ? video.file.url : video.file.current_path
    movie         = FFMPEG::Movie.new(video_path)
    audio_file    = Tempfile.new(["audio", ".flac"])
    movie.transcode(audio_file.path, audio_codec: 'flac', audio_bitrate: 64)

    # audio_flac    = Tempfile.new(["audio", ".flac"])
    # movie.transcode(audio_flac.path, {audio_codec: "flac"})

    binary_file   = File.binread audio_file
    file_content = { content: binary_file }

    operation = speech.long_running_recognize config: video_config(movie.audio_channels, movie.audio_sample_rate), audio: file_content
    operation.wait_until_done!
    results = operation.response.results

    words_hash = {}
    get_transcript(results, words_hash)
    Transcript.create(transcript: words_hash, video: video )
    audio_file.close
    audio_file.unlink
  end

  private

  def get_transcript(results, words_hash)
    results.each do |word|
      word.alternatives.first.words.each do |word|
        if words_hash.has_key?(word)
          words_hash[word.word] << word.start_time.seconds
        else
          words_hash[word.word] = [word.start_time.seconds]
        end
      end
    end
  end
end
