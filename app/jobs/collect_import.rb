class CollectImport
  @queue = :collect
  extend Limiting
  def self.perform
    Resque.logger = Logger.new("#{Rails.root}/log/collect_import.log")
    Resque.logger.level = Logger::DEBUG
    Resque.logger.info 'COLLECT IMPORT Job starts'

    count = ShopifyAPI::Collect.find(:count)
    Resque.logger.info "collects to process#{count.count}"
    pages = count.count.to_i % 250
    start = Time.now
    1.upto(pages) do |page|
      throttle_check
      collects = ShopifyAPI::Collect.find(:all, params: {limit:250, page:page})
      collects.each do |shopify_collect|
        Resque.logger.info "Collect_ID: #{shopify_collect.id}, Collection_ID: #{shopify_collect.collection_id}, Product_ID: #{shopify_collect.product_id}"
        begin
          Collect.upsert(
            id: shopify_collect.id,
            custom_collection_id: shopify_collect.collection_id,
            product_id: shopify_collect.product_id,
            created_at: shopify_collect.created_at,
            featured: shopify_collect.featured,
            position: shopify_collect.position,
            sort_value: shopify_collect.sort_value,
            updated_at: shopify_collect.updated_at
          )
        rescue StandardError => e
          Resque.logger.error "Collect(id: #{shopify_collect.id} table error: #{e})"
          next
        end
      end

    end
    Resque.logger.info "Done, Runtime: #{Time.now - start} seconds"
  end
end
