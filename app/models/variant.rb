class Variant < ApplicationRecord
  belongs_to :product
  has_many :metafields, as: :owner
end
