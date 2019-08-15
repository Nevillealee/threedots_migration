class CreateInventoryLevels < ActiveRecord::Migration[6.0]
  def change
    create_table :inventory_levels do |t|
      t.references :inventory_item, null: false, foreign_key: true #read only
      t.integer :available
      t.bigint :location_id
      t.datetime :updated_at #read only
    end
  end
end
