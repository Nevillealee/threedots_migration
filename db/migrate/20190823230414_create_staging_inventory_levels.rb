class CreateStagingInventoryLevels < ActiveRecord::Migration[6.0]
  def change
    create_table :staging_inventory_levels do |t|
      # t.id doesnt exist on ShopifyAPI, populated as InventoryItem Id
      t.references :staging_inventory_item, null: false, foreign_key: true #read only
      t.integer :available
      t.bigint :location_id
      t.datetime :updated_at #read only
    end
  end
end
