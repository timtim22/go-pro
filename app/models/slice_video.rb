class SliceVideo < ApplicationRecord
  include ActionView::Helpers::DateHelper
  mount_uploader :file, VideoUploader

  belongs_to :video
  belongs_to :audio
  belongs_to :user
  has_one :transcript, as: :transcriptable

  scope :recent, -> { where('slice_videos.created_at >= ?', 24.hours.ago) }

  def relative_time_since_creation
    time_ago_in_words(created_at)
  end
end
