class AddIndexToPartner < ActiveRecord::Migration[5.2]
  def change
  	add_index :partners, :coverage,      using: :gist
  end
end
