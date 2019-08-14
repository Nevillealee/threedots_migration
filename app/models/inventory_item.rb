class InventoryItem < ApplicationRecord
  belongs_to :variant
  has_one :inventory_level
end
