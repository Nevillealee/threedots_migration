class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      # id column auto generated
      t.string :body_html
      t.string :handle
      t.datetime :created_at
      t.jsonb :images
      t.jsonb :options
      t.string :product_type
      t.datetime :published_at
      t.string :published_scope
      t.string :tags
      t.string :template_suffix
      t.string :title
      t.string :metafields_global_title_tag
      t.string :metafields_global_description_tag
      t.datetime :updated_at
      t.string :vendor
    end
  end
end
