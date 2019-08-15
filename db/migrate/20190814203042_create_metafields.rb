class CreateMetafields < ActiveRecord::Migration[6.0]
  def change
    create_table :metafields do |t|
      t.bigint :owner_id
      t.string :owner_type #maps to owner_resource in shopify
      t.datetime :created_at #read only
      t.datetime :updated_at #read only
      t.string :description
      t.string :key
      t.string :namespace
      t.string :value
      t.string :value_type
    end
    add_index :metafields, [:owner_type, :owner_id]
  end
end
