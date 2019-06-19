class CreatePartners < ActiveRecord::Migration[5.2]
  def change
    create_table :partners do |t|
      t.string :name
      t.string :phone, :null => false
      t.integer :status, :default => 0
      t.st_point :location
      t.geometry :coverage
      t.timestamps
    end
  end
end
