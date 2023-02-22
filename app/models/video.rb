class Video < ApplicationRecord
  mount_uploader :file, VideoUploader
  belongs_to :user
  has_one :transcript
  storage :fog
end
