class CreateStagingProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :staging_products do |t|
      # id column auto generated
      t.string :title
      t.string :handle
      t.string :body_html
      t.datetime :created_at
      t.jsonb :options
      t.string :product_type
      t.datetime :published_at
      t.string :published_scope
      t.string :tags
      t.string :template_suffix
      t.datetime :updated_at
      t.string :vendor
    end
  end
end
