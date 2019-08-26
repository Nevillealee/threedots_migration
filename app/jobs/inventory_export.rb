# dependant on variant tables (staging/active) being updated
class InventoryExport
  include HTTParty
  @queue = :staging_inventory
  base_uri  ENV['STAGING_BASE_URI']

  def self.perform
    start = Time.now
    Resque.logger = ::Logger.new("#{Rails.root}/log/inventory_export.log")
    Resque.logger.info 'INVENTORY EXPORT Job starts'
    active_variants = Variant.joins("INNER JOIN staging_variants sv ON variants.sku = sv.sku
      WHERE sv.inventory_quantity <> variants.inventory_quantity");
      Resque.logger.info "#{active_variants.size} Inventory Levels to update.."
    active_variants.each do |a_variant|
      begin
        staging_variant = a_variant.get_staging
        Resque.logger.debug "Active variant: #{a_variant.id} mapped to Staging Variant #{staging_variant.id}"
        my_body = format_var_body(staging_variant, a_variant.inventory_quantity)
        options = { body: my_body }
        res = post("#{base_uri}/#{ENV['API_VERSION']}/inventory_levels/set.json", options)

        Resque.logger.info "#{res.parsed_response}\n\n"
        call_limit = res.headers['x-shopify-shop-api-call-limit']

        if call_limit.to_i > 35
          Resque.logger.debug "CALL LIMIT REACHED: #{call_limit}, sleeping 15"
          sleep 15
        end

        if res.code == 201 || res.code == 200
          update_local_staging_qty(res.parsed_response['inventory_level'], staging_variant.id)
        else
          Resque.logger.warn "FAILURE!!!!! HTTP CODE: #{res.code}"
        end
      rescue StandardError => e
        Resque.logger.error e
        next
      end #end of rescue block
      Resque.logger.info "Staging Inventory Level (#{staging_variant.id}) saved (in staging variant) to local DB!"
    end
    Resque.logger.info"done, rumtime #{Time.now - start} seconds"
  end

  def self.format_var_body(stage_vrnt, new_qty)
    return {
      location_id: ENV['STAGING_LOCATION_ID'],
      inventory_item_id: stage_vrnt.inventory_item_id,
      available: new_qty,
    }
  end

  def self.update_local_staging_qty(res_inv_level, stage_var_id)
    begin
      StagingVariant.find_by_id(stage_var_id).update!(
        inventory_quantity: res_inv_level['available']
      )
    rescue StandardError => e
      Resque.logger.error "Local update error: #{e}"
    end #end of rescue block
  end
end
