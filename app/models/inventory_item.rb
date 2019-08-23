class InventoryItem < ApplicationRecord
  has_one :inventory_level
end
