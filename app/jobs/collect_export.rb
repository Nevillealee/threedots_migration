class CollectExport
  include HTTParty
  @queue = :collect
  base_uri  ENV['STAGING_BASE_URI']

  def self.perform
    start = Time.now
    Resque.logger = ::Logger.new("#{Rails.root}/log/collect_export.log")
    Resque.logger.info 'COLLECT EXPORT Job starts'

    active_collects = Collect.all
    Resque.logger.info "#{active_collects.size} collects to process..."

    active_collects.each do |collect|
      begin
        staging_prod = Product.find(collect.product_id).get_staging
        staging_collection = CustomCollection.find(collect.custom_collection_id).get_staging

        my_body = format_collect_body(staging_prod.id, staging_collection.id)
        options = { body: my_body }
        res = post("#{base_uri}/#{ENV['API_VERSION']}/collects.json", options)

        Resque.logger.info res.parsed_response
        call_limit = res.headers['x-shopify-shop-api-call-limit']

        if call_limit.to_i > 35
          Resque.logger.debug "CALL LIMIT REACHED: #{call_limit}, sleeping 15"
          sleep 15
        end

        if res.code == 422
          Resque.logger.warn "FAILURE!!!!! HTTP CODE: #{res.code}"
        else
          Resque.logger.info "HTTP RESPONSE CODE: #{res.code}"
        end

        Resque.logger.info "------------> x-shopify-shop-api-call-limit: #{call_limit}\n\n"
      rescue StandardError => e
        Resque.logger.error "StagingCollect(id: #{res.parsed_response['collect']['id']}) table error: #{e}"
        next
      end #end of rescue block
    end
    Resque.logger.info "Runtime: #{Time.now - start} seconds"
  end

  def self.format_collect_body(prod_id, col_id)
    return {
      collect: {
        product_id: prod_id,
        collection_id: col_id
      }
    }
  end
end
