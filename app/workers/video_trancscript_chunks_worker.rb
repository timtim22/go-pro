class VideoTrancscriptChunksWorker
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

    def split_audio_file(audio_path, segment_duration)
      segments = []
      output_template = "#{audio_path}-segment-%03d.flac"
    
      # Create FFmpeg input options
      input_options = {i: audio_path}
    
      # Create FFmpeg output options
      output_options = {
        f: 'segment',
        segment_time: 10,
        segment_format: 'flac',
        acodec: 'flac',
        ab: '64k',
        '%03d': output_template
      }
    
      # Run FFmpeg to split the audio file into segments
      transcoder = FFMPEG::Transcoder.new(input_options, output_template, output_options)
      transcoder.run
    
      # Collect the output segment paths
      Dir.glob("#{audio_path}-segment-*.flac").each do |segment_path|
        segments << segment_path
      end
    
      segments
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
end
