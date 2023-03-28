class CreateSliceVideo < ActiveRecord::Migration[6.1]
  def change
    create_table :slice_videos do |t|
      t.string :file
      t.string :title
      t.text :description
      t.integer :video_id

      t.timestamps
    end
  end
end
