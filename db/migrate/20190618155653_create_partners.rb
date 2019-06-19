class CreatePartners < ActiveRecord::Migration[5.2]
  def change
    create_table :partners do |t|
      t.string :name
      t.string :phone, :null => false
      t.integer :status, :default => 0
      t.st_point :location, :geographic => true
      t.st_polygon :coverage, :geographic => true
      t.timestamps
    end
  end
end
