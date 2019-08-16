class CreateVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :barcode
      t.string :compare_at_price
      t.datetime :created_at
      t.string :fulfillment_service
      t.integer :grams
      t.bigint :image_id
      t.bigint :inventory_item_id
      t.string :inventory_management
      t.string :inventory_policy
      t.integer :inventory_quantity #read only
      t.string :option1
      t.string :option2
      t.string :option3
      t.integer :position #read only
      t.string :price
      t.string :sku
      t.boolean :taxable
      t.string :title
      t.datetime :updated_at
      t.integer :weight
      t.string :weight_unit
    end
  end
end
