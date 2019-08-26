class PageExport
  include HTTParty
  @queue = :staging_page
  extend Limiting
  base_uri  ENV['STAGING_BASE_URI']

  def self.perform
    Resque.logger = ::Logger.new("#{Rails.root}/log/page_export.log")
    Resque.logger.info 'PAGE EXPORT Job start'
    start = Time.now
    active_pages = Page.joins("LEFT JOIN staging_pages ON pages.handle = staging_pages.handle").where("staging_pages.handle": nil)
    Resque.logger.info "staging pages to process #{active_pages.size}"

    if active_pages.size > 0
      active_pages.each do |a_page|
        my_body = format_page_body(a_page)
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
    StagingPage.upsert(
      id: staging_page['id'],
      author: staging_page['author'],
      created_at: staging_page['created_at'],
      handle: staging_page['handle'],
      published_at: staging_page['published_at'],
      shop_id: staging_page['shop_id'],
      template_suffix: staging_page['template_suffix'],
      title: staging_page['title'],
      updated_at: staging_page['updated_at'],
      body_html: staging_page['body_html']
    )
    Resque.logger.info "Staging Page (#{staging_page['title']}) saved to local DB!"
  end

  def self.format_page_body(page)
    return {
      page: {
        title: page.title,
        body_html: page.body_html,
        author: page.author,
        handle: page.handle,
        template_suffix: page.template_suffix,
        published_at: page.published_at,
      }
    }
  end
end
