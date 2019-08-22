class InventoryLevel < ApplicationRecord
  belongs_to :inventory_item, optional: true
end
