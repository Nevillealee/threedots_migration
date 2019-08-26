class CreateStagingPages < ActiveRecord::Migration[6.0]
  def change
    create_table :staging_pages do |t|
      t.string :author
      t.string :body_html
      t.datetime :created_at #read only
      t.string :handle
      t.datetime :published_at
      t.bigint :shop_id #read only
      t.string :template_suffix
      t.string :title
      t.datetime :updated_at
    end
  end
end
