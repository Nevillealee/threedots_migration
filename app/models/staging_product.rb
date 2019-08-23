class StagingProduct < ApplicationRecord
  include ShopifyAPI
  has_many :staging_variants
  has_many :staging_images
end
