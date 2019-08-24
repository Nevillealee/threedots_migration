class Product < ApplicationRecord
  include ShopifyAPI
  has_many :variants
  has_many :images
  has_many :collects
  has_many :custom_collections, through: :collects
  has_many :metafields, as: :owner

  def get_staging
    StagingProduct.find_by_handle(handle)
  end
end
