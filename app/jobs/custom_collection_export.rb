class CustomCollectionExport
  include HTTParty
  @queue = :staging_custom_collection
  base_uri  ENV['STAGING_BASE_URI']

  def self.perform
    start = Time.now
    Resque.logger = ::Logger.new("#{Rails.root}/log/custom_collection_export.log")
    Resque.logger.info 'STAGING CUSTOM COLLECTION EXPORT Job starts'
    active_collections = CustomCollection.joins("LEFT JOIN staging_custom_collections ON custom_collections.handle = staging_custom_collections.handle").where("staging_custom_collections.handle": nil)
    if active_collections.size > 0
      active_collections.each do |active_collection|
        my_body = format_collection_body(active_collection)
        options = { body: my_body }
        res = post("#{base_uri}/#{ENV['API_VERSION']}/custom_collections.json", options)

        Resque.logger.info res.parsed_response
        call_limit = res.headers['x-shopify-shop-api-call-limit']

        if call_limit.to_i > 35
          Resque.logger.debug "CALL LIMIT REACHED: #{call_limit}, sleeping 15"
          sleep 15
        end

        if res.code == 201 || res.code == 200
          create_local(res.parsed_response['custom_collection'])
        else
          Resque.logger.warn "FAILURE!!!!! HTTP CODE: #{res.code}"
        end

        Resque.logger.info "HTTP RESPONSE CODE: #{res.code}"
        Resque.logger.info "------------> x-shopify-shop-api-call-limit: #{call_limit}\n\n"
      end
    else
      Resque.logger.info "No collections were updated"
    end
    Resque.logger.info "Runtime: #{Time.now - start} seconds"
  end

  def self.format_collection_body(collection)
    return {
      custom_collection: {
        title: collection.title,
        body_html: collection.body_html,
        published: collection.published,
        sort_order: collection.sort_order,
        template_suffix: collection.template_suffix,
        handle: collection.handle
      }
    }
  end

  def self.create_local(stage_collection)
    begin
      StagingCustomCollection.upsert(
        id: stage_collection['id'],
        body_html: stage_collection['body_html'],
        handle: stage_collection['handle'],
        published_at: stage_collection['published_at'],
        published_scope: stage_collection['published_scope'],
        sort_order: stage_collection['sort_order'],
        template_suffix: stage_collection['template_suffix'],
        title: stage_collection['title'],
        updated_at: stage_collection['updated_at']
      )
      Resque.logger.info "Staging Custom Collection(#{stage_collection['title']}) saved to local DB!"
    rescue StandardError => e
      Resque.logger.error "StagingCustomCollection(id: #{stage_collection['id']}) table error: #{e}"
    end
  end
end
