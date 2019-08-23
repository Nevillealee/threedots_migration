class CustomCollectionImport
  @queue = :custom_collection
  extend Limiting
  def self.perform
    Resque.logger = Logger.new("#{Rails.root}/log/custom_collection_import.log")
    Resque.logger.level = Logger::DEBUG
    Resque.logger.info 'CUSTOM COLLECTION IMPORT Job starts'

    count = ShopifyAPI::CustomCollection.find(:count)
    Resque.logger.info "custom collections to process #{count.count}"
    pages = count.count.to_i % 250
    start = Time.now
    1.upto(pages) do |page|
      #wtf is this
      throttle_check
      custom_collections = ShopifyAPI::CustomCollection.find(:all, params: {limit: 250, page: page})
      custom_collections.each do|shopify_cust_collection|
        Resque.logger.info "Collection_ID: #{shopify_cust_collection.id}, title: #{shopify_cust_collection.title}"
        #whats begin? like try catch?
        begin
          CustomCollection.upsert(
            id: shopify_cust_collection.id,
            body_html: shopify_cust_collection.body_html,
            handle: shopify_cust_collection.handle,
            #image: shopify_cust_collection.image,
            published_at: shopify_cust_collection.published_at,
            published_scope: shopify_cust_collection.published_scope,
            sort_order: shopify_cust_collection.sort_order,
            template_suffix: shopify_cust_collection.template_suffix,
            title: shopify_cust_collection.title,
            updated_at: shopify_cust_collection.updated_at
          )
        rescue StandardError => e
          Resque.logger.error "CustomCollection(id: #{shopify_cust_collection.id}) table error: #{e}"
          next
        end
      end
    end
    Resque.logger.info "Done, Runtime: #{Time.now - start} seconds"
  end
end
