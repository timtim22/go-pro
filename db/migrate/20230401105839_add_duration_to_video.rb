class AddDurationToVideo < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :duration, :float
  end
end
