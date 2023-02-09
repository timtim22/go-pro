class CreateVideos < ActiveRecord::Migration[6.1]
  def change
    create_table :videos do |t|
      t.string :file
      t.string :title
      t.text :description
      t.integer :user_id

      t.timestamps
    end
  end
end
