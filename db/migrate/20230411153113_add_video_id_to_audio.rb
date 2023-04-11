class AddVideoIdToAudio < ActiveRecord::Migration[6.1]
  def change
    add_column :audios, :video_id, :integer
  end
end
