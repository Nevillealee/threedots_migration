# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_08_14_212022) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "collects", force: :cascade do |t|
    t.bigint "custom_collection_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at"
    t.boolean "featured"
    t.integer "position"
    t.string "sort_value"
    t.datetime "updated_at"
    t.index ["custom_collection_id"], name: "index_collects_on_custom_collection_id"
    t.index ["product_id"], name: "index_collects_on_product_id"
  end

  create_table "custom_collections", force: :cascade do |t|
    t.string "body_html"
    t.string "handle"
    t.jsonb "image"
    t.boolean "published"
    t.datetime "published_at"
    t.string "published_scope"
    t.string "sort_order"
    t.string "template_suffix"
    t.string "title"
    t.datetime "updated_at"
  end

  create_table "images", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.datetime "created_at"
    t.integer "position"
    t.integer "variant_ids", array: true
    t.string "src"
    t.integer "width"
    t.integer "height"
    t.datetime "updated_at"
    t.index ["product_id"], name: "index_images_on_product_id"
  end

  create_table "inventory_items", force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.string "cost"
    t.string "country_code_of_origin"
    t.json "country_harmonized_system_codes"
    t.datetime "created_at"
    t.bigint "harmonized_system_code"
    t.string "province_code_of_origin"
    t.string "sku"
    t.boolean "tracked"
    t.datetime "updated_at"
    t.boolean "requires_shipping"
    t.index ["variant_id"], name: "index_inventory_items_on_variant_id"
  end

  create_table "inventory_levels", force: :cascade do |t|
    t.bigint "inventory_item_id", null: false
    t.integer "available"
    t.bigint "location_id"
    t.datetime "updated_at"
    t.index ["inventory_item_id"], name: "index_inventory_levels_on_inventory_item_id"
  end

  create_table "metafields", force: :cascade do |t|
    t.bigint "owner_id"
    t.string "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "description"
    t.string "key"
    t.string "namespace"
    t.string "value"
    t.string "value_type"
    t.index ["owner_type", "owner_id"], name: "index_metafields_on_owner_type_and_owner_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "author"
    t.string "body_html"
    t.datetime "created_at"
    t.string "handle"
    t.datetime "published_at"
    t.bigint "shop_id"
    t.string "template_suffix"
    t.string "title"
    t.datetime "updated_at"
  end

  create_table "products", force: :cascade do |t|
    t.string "title"
    t.string "handle"
    t.string "body_html"
    t.datetime "created_at"
    t.jsonb "options"
    t.string "product_type"
    t.datetime "published_at"
    t.string "published_scope"
    t.string "tags"
    t.string "template_suffix"
    t.string "metafields_global_title_tag"
    t.string "metafields_global_description_tag"
    t.datetime "updated_at"
    t.string "vendor"
  end

  create_table "variants", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "barcode"
    t.string "compare_at_price"
    t.datetime "created_at"
    t.string "fulfillment_service"
    t.integer "grams"
    t.bigint "image_id"
    t.bigint "inventory_item_id"
    t.string "inventory_management"
    t.string "inventory_policy"
    t.integer "inventory_quantity"
    t.string "option1"
    t.string "option2"
    t.string "option3"
    t.jsonb "presentment_prices"
    t.integer "position"
    t.string "price"
    t.string "sku"
    t.boolean "taxable"
    t.string "tax_code"
    t.string "title"
    t.datetime "updated_at"
    t.integer "weight"
    t.string "weight_unit"
    t.index ["product_id"], name: "index_variants_on_product_id"
  end

  add_foreign_key "collects", "custom_collections"
  add_foreign_key "collects", "products"
  add_foreign_key "images", "products"
  add_foreign_key "inventory_items", "variants"
  add_foreign_key "inventory_levels", "inventory_items"
  add_foreign_key "variants", "products"
end
