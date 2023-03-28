class Transcript < ApplicationRecord
  belongs_to :transcriptable, polymorphic: true
end
