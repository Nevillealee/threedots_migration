class CreateCollects < ActiveRecord::Migration[6.0]
  def change
    create_table :collects do |t|
      t.references :custom_collection, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.datetime :created_at
      t.boolean :featured
      t.integer :position
      t.string :sort_value
      t.datetime :updated_at
    end
  end
end
