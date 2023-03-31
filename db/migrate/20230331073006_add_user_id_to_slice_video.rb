class AddUserIdToSliceVideo < ActiveRecord::Migration[6.1]
  def change
    add_column :slice_videos, :user_id, :integer
  end
end
