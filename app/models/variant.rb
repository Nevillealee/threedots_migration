class Variant < ApplicationRecord
  belongs_to :product
  has_many :metafields, as: :owner

  def get_staging
    StagingVariant.where(sku: sku, price: price).first
  end
end
