class VideoTranscriptWorker
  include Sidekiq::Worker
  include VideoTranscriptConfigHelper

  def perform(video_id)
    video         = Video.find_by(id: video_id)
    speech        = Google::Cloud::Speech.speech
    video_path    = Rails.env.production? ? video.file.url : video.file.current_path
    movie         = FFMPEG::Movie.new(video_path)
    audio_file    = Tempfile.new(["audio", ".flac"])
    movie.transcode(audio_file.path, audio_codec: 'flac', audio_bitrate: 16000)

    binary_file   = File.binread(audio_file)
    file_content = { content: binary_file }

    operation = speech.long_running_recognize config: video_config(movie.audio_channels, movie.audio_sample_rate), audio: file_content
    operation.wait_until_done!
    results = operation.response.results

    words_array = get_transcript(results)
    Transcript.create(transcript: words_array, video: video, results: results )
    audio_file.close
    audio_file.unlink
  end

  private

  def get_transcript(results)
    words_array = []
    results.each do |word|
      word.alternatives.first.words.each do |word|
        words_array << { "videoTranscriptword" => word.word, "videoTime" => word.start_time.seconds }
      end
    end
    words_array
  end
end


binary_data = File.binread(chunk_path)
  operation = speech.long_running_recognize config: video_config(movie.audio_channels, movie.audio_sample_rate), audio: {content: binary_data}
  operation.wait_until_done!
  results = operation.response.results
  words_hash = {}
  get_transcript(results, words_hash)
  transcripts << words_hash