class StagingInventoryItem < ApplicationRecord
  has_one :staging_inventory_level
end
