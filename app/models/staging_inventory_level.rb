class StagingInventoryLevel < ApplicationRecord
  belongs_to :staging_inventory_item, optional: true
end
