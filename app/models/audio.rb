class Audio < ApplicationRecord
  include ActionView::Helpers::DateHelper
  mount_uploader :file, AudioUploader

  has_one :transcript, as: :transcriptable
  belongs_to :video

end
