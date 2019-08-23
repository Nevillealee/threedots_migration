class PageImport
  @queue = :page
  extend Limiting
  def self.perform
    Resque.logger = Logger.new("#{Rails.root}/log/page_import.log")
    Resque.logger.level = Logger::DEBUG
    Resque.logger.info 'PAGE IMPORT Job start'

    count = ShopifyAPI::Page.find(:count)
    Resque.logger.info "pages to process #{count.count}"
    pages = count.count.to_i % 250
    start = Time.now
    1.upto(pages) do |page|
      throttle_check
      page_api = ShopifyAPI::Page.find(:all, params:{limit:250, page:page})
      page_api.each do |shopify_page|
        Resque.logger.info "Page_ID: #{shopify_page.id} shop_id: #{shopify_page.shop_id}"
        begin
          Page.upsert(
            id: shopify_page.id,
            author: shopify_page.author,
            created_at: shopify_page.created_at,
            handle: shopify_page.handle,
            published_at: shopify_page.published_at,
            shop_id: shopify_page.shop_id,
            template_suffix: shopify_page.template_suffix,
            title: shopify_page.title,
            updated_at: shopify_page.updated_at,
            body_html: shopify_page.body_html
          )
        rescue ExceptionName => e
          Resque.logger.error "Page(id: #{shopify_page.id} table error#{e})"
          next
        end
      end
    end
     Resque.logger.info"done, rumtime #{Time.now - start} seconds"
  end
end
