class CreateTranscript < ActiveRecord::Migration[6.1]
  def change
    create_table :transcripts do |t|
      t.json :transcript
      t.integer :video_id

      t.timestamps
    end
  end
end
