class AddIndexToTask < ActiveRecord::Migration[5.2]
  def change
  	add_index :tasks, [:partner_id, :status], :unique => true, :name => "partner_id_status_composite_index"
  end
end
