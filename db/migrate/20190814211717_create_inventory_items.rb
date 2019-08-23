class CreateInventoryItems < ActiveRecord::Migration[6.0]
  def change
    create_table :inventory_items do |t|
      t.string :cost
      t.string :country_code_of_origin
      t.json :country_harmonized_system_codes
      t.datetime :created_at #read only
      t.bigint :harmonized_system_code
      t.string :province_code_of_origin
      t.string :sku
      t.boolean :tracked
      t.datetime :updated_at #read only
      t.boolean :requires_shipping #read only
    end
  end
end
