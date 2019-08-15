class CreateCustomCollections < ActiveRecord::Migration[6.0]
  def change
    create_table :custom_collections do |t|
      t.string :body_html
      t.string :handle
      t.jsonb :image
      t.boolean :published
      t.datetime :published_at #read only
      t.string :published_scope
      t.string :sort_order
      t.string :template_suffix
      t.string :title
      t.datetime :updated_at #read only
    end
  end
end
