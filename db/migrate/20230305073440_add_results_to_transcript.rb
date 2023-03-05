class AddResultsToTranscript < ActiveRecord::Migration[6.1]
  def change
    add_column :transcripts, :results, :text
  end
end
