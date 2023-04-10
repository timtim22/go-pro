class Video < ApplicationRecord
  include ActionView::Helpers::DateHelper
  mount_uploader :file, VideoUploader

  belongs_to :user
  belongs_to :audio
  has_one :transcript, as: :transcriptable
  has_many :slice_videos

  scope :recent, -> { where('videos.created_at >= ?', 24.hours.ago) }

  def relative_time_since_creation
    time_ago_in_words(created_at)
  end
end
