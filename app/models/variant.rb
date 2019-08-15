class Variant < ApplicationRecord
  belongs_to :product
  has_many :metafields, as: :owner
  has_one :inventory_item
  has_one :inventory_level, through: :inventory_item
end
