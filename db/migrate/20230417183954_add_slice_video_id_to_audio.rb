class AddSliceVideoIdToAudio < ActiveRecord::Migration[6.1]
  def change
    add_column :audios, :slice_video_id, :integer
  end
end
