class CustomCollection < ApplicationRecord
  has_many :collects
  has_many :products, through: :collects
  has_many :metafields, as: :owner
end
