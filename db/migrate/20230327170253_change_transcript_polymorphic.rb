class ChangeTranscriptPolymorphic < ActiveRecord::Migration[6.1]
  def change
    add_column :transcripts, :transcriptable_id, :integer
    add_column :transcripts, :transcriptable_type, :string
    remove_column :transcripts, :video_id
  end
end
