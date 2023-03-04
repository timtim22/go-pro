class VideoTranscriptChunksWorker
  include Sidekiq::Worker
  include VideoTranscriptConfigHelper

  def perform(video_id)
    video         = Video.find_by(id: video_id)
    speech        = Google::Cloud::Speech.speech
    video_path    = Rails.env.production? ? video.file.url : video.file.current_path
    movie         = FFMPEG::Movie.new(video_path)
    audio_file    = Tempfile.new(["audio", ".flac"])
    movie.transcode(audio_file.path, audio_codec: 'flac', audio_bitrate: 64)

    chunks = split_audio_file(audio_file.path, 10)

    transcripts = []
    chunks.each do |chunk_path|
      binary_file   = File.binread(chunk_path)
      file_content = { content: binary_file }

      operation = speech.long_running_recognize config: video_config(movie.audio_channels, movie.audio_sample_rate), audio: file_content
      operation.wait_until_done!
      results = operation.response.results

      words_hash = {}
      get_transcript(results, words_hash)
      transcripts << words_hash
    end

    full_transcript = combine_transcripts(transcripts)

    Transcript.create(transcript: full_transcript, video: video)

    audio_file.close
    audio_file.unlink

    def split_audio_file(audio_path, chunk_length)
      chunks = []
      movie = FFMPEG::Movie.new(audio_path)
      duration = movie.duration
    
      (0..(duration/chunk_length)).each do |i|
        start_time = i * chunk_length
        end_time = [start_time + chunk_length, duration].min
        chunk_path = "#{audio_path}-#{i}.flac"
        movie.transcode(chunk_path, ss: start_time, t: chunk_length, audio_codec: 'flac', audio_bitrate: 64)
        chunks << chunk_path
      end
    
      chunks
    end

    def combine_transcripts(transcripts)
      full_transcript = {}
      transcripts.each do |transcript|
        transcript.each do |word, times|
          if full_transcript.has_key?(word)
            full_transcript[word] += times
          else
            full_transcript[word] = times
          end
        end
      end
    
      full_transcript
    end
  end
end
