module VideoTranscriptConfigHelper
  extend ActiveSupport::Concern

  def video_config(channel, rate_hertz)
    { 
      encoding:            "FLAC",
      audio_channel_count: channel,
      sample_rate_hertz:   rate_hertz,
      language_code:       "en-US",
      enable_word_time_offsets: true
    }
  end
end