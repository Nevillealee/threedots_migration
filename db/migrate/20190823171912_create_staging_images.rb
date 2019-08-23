class CreateStagingImages < ActiveRecord::Migration[6.0]
  def change
    create_table :staging_images do |t|
      t.references :staging_product, null: false, foreign_key: true
      t.datetime :created_at
      t.integer :position
      t.bigint :variant_ids, array: true #variant ids associated with the image.
      t.string :src
      t.integer :width
      t.integer :height
      t.datetime :updated_at
    end
  end
end
