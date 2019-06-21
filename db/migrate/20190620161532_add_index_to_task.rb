class AddIndexToTask < ActiveRecord::Migration[5.2]
  def change
  	add_index :tasks, [:partner_id, :updated_at], :unique => true, :name => "partner_id_updated_at_composite_index"
  end
end
