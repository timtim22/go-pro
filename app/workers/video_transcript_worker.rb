class VideoTranscriptWorker
  include Sidekiq::Worker
  include VideoTranscriptConfigHelper
  require 'open-uri'

  def perform(video_id, type)
    video         = type == 'video' ? Video.find_by(id: video_id) : SliceVideo.find_by(id: video_id)
    speech        = Google::Cloud::Speech.speech
    video_path    = Rails.env.production? ? video.file.url : video.file.current_path
    movie         = FFMPEG::Movie.new(video_path)

    audio = Audio.new
    audio_file     = CarrierWave::SanitizedFile.new(File.join(Rails.root, "tmp", "audio_#{Time.now.to_i}.wav"))
    movie.transcode(audio_file.path, audio_codec: 'pcm_s16le', audio_bitrate: 44100)
    audio.file     = audio_file
    type == 'video' ? audio.video_id = video.id : audio.slice_video_id = video.id
    audio.save!
    duration = movie.duration

    video.update(duration: duration) if type == 'video'

    chunk_duration = 20
    total_chunks = (movie.duration / chunk_duration).ceil
    words_array = []
    # results = ""

    thread_pool = Concurrent::FixedThreadPool.new(10)
    mutex = Mutex.new
    begin
      total_chunks.times do |chunk_index|
        thread_pool.post do
          begin
          start_time = chunk_index * chunk_duration
          end_time = [start_time + chunk_duration, movie.duration].min
        
          chunk_file = Tempfile.new(["chunk_#{chunk_index}", ".wav"])
          `ffmpeg -y -i #{audio_file.path} -ss #{start_time} -t #{end_time - start_time} -vn -acodec copy #{chunk_file.path}`
      
          binary_file = File.binread(chunk_file)
          file_content = {content: binary_file}
      
          operation = speech.long_running_recognize config: video_config(movie.audio_channels, movie.audio_sample_rate), audio: file_content
          operation.wait_until_done!
          results = operation.response.results
      
          chunk_words_array = get_transcript(results, start_time, duration)
          mutex.synchronize { words_array.concat(chunk_words_array) }
          
          chunk_file.close
          chunk_file.unlink
          rescue => e
            puts "Error in thread: #{e.message}"
            puts e.backtrace
          end
        end
      end
    ensure
      thread_pool.shutdown
      thread_pool.wait_for_termination
    end

    Transcript.create(transcript: words_array, transcriptable: video, results: 'results')
    audio.destroy
  end

  private

  def format_seconds_to_time(seconds)
    Time.at(seconds).utc.strftime("%H:%M:%S")
  end
  
  def get_transcript(results, start_time, duration)
    words_array = []
    results.each do |word|
      word.alternatives.first.words.each do |word|
        video_time = word.start_time.seconds + start_time
        start_time_format = format_seconds_to_time(video_time)
        end_time = [video_time + 15, duration].min
        end_time_format = format_seconds_to_time(end_time)
        
        words_array << {
          "videoTranscriptword" => word.word,
          "videoTime" => video_time,
          "startTimeFormat" => start_time_format,
          "endTimeFormat" => end_time_format
        }
      end
    end
    words_array
  end
end


def get_sentences_with_keyword(transcript)
  sentences = []
  current_sentence = []
  
  transcript.each do |word_data|
    word = word_data["videoTranscriptword"]
    current_sentence << word

    if word[-1] == '.' || word[-1] == '?' || word[-1] == '!'
      sentence = current_sentence.join(' ')
      # if sentence.include?(keyword)
        sentences << {
          'sentence' => sentence,
          'startTimeFormat' => word_data["startTimeFormat"],
          'endTimeFormat' => word_data["endTimeFormat"]
        }
      # end
      current_sentence = []
    end
  end

  sentences
end