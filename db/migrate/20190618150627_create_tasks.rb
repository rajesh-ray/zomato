class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.st_point :source, :null=>false
      t.st_point :destination, :null=>false
      t.integer :status
      t.integer :partner_id
      t.timestamps
    end
  end
end
