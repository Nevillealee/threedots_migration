class CreateStagingCollects < ActiveRecord::Migration[6.0]
  def change
    create_table :staging_collects do |t|
      t.references :staging_custom_collection, null: false, foreign_key: true
      t.references :staging_product, null: false, foreign_key: true
      t.datetime :created_at
      t.boolean :featured
      t.integer :position
      t.string :sort_value
      t.datetime :updated_at
    end
  end
end
