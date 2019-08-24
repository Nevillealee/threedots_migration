class StagingProduct < ApplicationRecord
  include ShopifyAPI
  has_many :staging_variants
  has_many :staging_images
  has_many :staging_custom_collections, through: :staging_collects
end
