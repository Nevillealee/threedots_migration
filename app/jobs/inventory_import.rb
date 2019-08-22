class InventoryImport
  @queue = :inventory
  def self.perform
    Resque.logger = Logger.new("#{Rails.root}/log/inventory_import.log")
    Resque.logger.level = Logger::DEBUG
    Resque.logger.info 'INVENTORY IMPORT Job starts'
    inv_item_ids = Variant.all.pluck(:inventory_item_id)
    count = ShopifyAPI::InventoryItem.find(:count, params: {inventory_item_ids: inv_item_ids})
  end
end
