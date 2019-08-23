class InventoryImport
  @queue = :inventory
  extend Limiting
  def self.perform
    Resque.logger = Logger.new("#{Rails.root}/log/inventory_import.log")
    Resque.logger.level = Logger::DEBUG
    Resque.logger.info 'INVENTORY IMPORT Job starts'
    inv_item_ids = Variant.all.pluck(:inventory_item_id)
    inv_id_chunks = inv_item_ids.each_slice(50).to_a
    count = inv_item_ids.size
    Resque.logger.info "#{count} InventoryItems to pull"
    # iterate through inv item ids 50 at a time (Inventory LEVEL api max)
    inv_id_chunks.each do |inv_chunk|
      inventory_items = ShopifyAPI::InventoryItem.find(:all, params: {ids: inv_chunk.to_s, limit: 50})
      inventory_items.each do |item|
        throttle_check
        begin
          InventoryItem.upsert(
            id: item.id,
            cost: item.cost,
            country_code_of_origin: item.country_code_of_origin,
            created_at: item.created_at,
            harmonized_system_code: item.harmonized_system_code,
            province_code_of_origin: item.province_code_of_origin,
            sku: item.sku,
            tracked: item.tracked,
            updated_at: item.updated_at,
            requires_shipping: item.requires_shipping
          )
        rescue StandardError => e
          Resque.logger.error "InventoryItem(id: #{item.id}) table error: #{e}"
          next
        end
      end
      inventory_levels = ShopifyAPI::InventoryLevel.find(:all, params: {inventory_item_ids: inv_chunk.to_s, limit: 50})
      inventory_levels.each do |level|
        throttle_check
        begin
          InventoryLevel.upsert(
            id: level.inventory_item_id,
            inventory_item_id: level.inventory_item_id,
            available: level.available,
            location_id: level.location_id,
            updated_at: level.updated_at
          )
        rescue StandardError => e
          Resque.logger.error "InventoryLevel(id: #{level.id}) table error: #{e}"
          next
        end
      end
    end #inv_id_chunks loop end
  end
end
