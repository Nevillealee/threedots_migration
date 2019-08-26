class PageExport
  @queue = :staging_page
  extend Limiting
  def self.perform
    Resque.logger = Logger.new("#{Rails.root}/log/page_export.log")
    Resque.logger.level = Logger::DEBUG
    Resque.logger.info 'PAGE EXPORT Job start'
    start = Time.now
    active_pages = Page.joins("LEFT JOIN staging_pages ON pages.title = staging_pages.title").where("staging_pages.title": nil)
    Resque.logger.info "staging pages to process #{active_pages.size}"

    if active_pages.size > 0
      active_pages.each do |a_pages|
        my_body = format_page_body(active_prod)
        options = { body: my_body }
        res = post("#{base_uri}/#{ENV['API_VERSION']}/pages.json", options)

        Resque.logger.info res.parsed_response
        call_limit = res.headers['x-shopify-shop-api-call-limit']

        if call_limit.to_i > 35
          Resque.logger.debug "CALL LIMIT REACHED: #{call_limit}, sleeping 15"
          sleep 15
        end

        if res.code == 201 || res.code == 200
          create_local(res.parsed_response['page'])
        else
          Resque.logger.warn "FAILURE!!!!! HTTP CODE: #{res.code}"
        end

        Resque.logger.info "HTTP RESPONSE CODE: #{res.code}"
        Resque.logger.info "------------> x-shopify-shop-api-call-limit: #{call_limit}\n\n"
      end
    else
      Resque.logger.info "No pages were updated"
    end
     Resque.logger.info"done, rumtime #{Time.now - start} seconds"
  end

  def self.create_local(staging_page)
    StagingPage
  end

  def self.format_page_body
  end
end
