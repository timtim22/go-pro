class Video < ApplicationRecord
  mount_uploader :file, VideoUploader
  belongs_to :user
  has_one :transcript
end
