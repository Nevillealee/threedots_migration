class ProductImport
  @queue = :product
  def self.perform
    #initialize class and run pull
    count = ShopifyAPI::Product.find(:count)
    pages = count.count.to_i % 250
    1.upto(pages) do |page|
      products = ShopifyAPI::Product.find(:all, params: {limit: 250, page: page})
      products.each do |shopify_prod|
        Product.upsert(
          id: shopify_prod.id,
          body_html: shopify_prod.body_html,
          handle: shopify_prod.handle,
          created_at: shopify_prod.created_at,
          options: shopify_prod.options.to_json,
          product_type: shopify_prod.product_type,
          published_at: shopify_prod.published_at,
          published_scope: shopify_prod.published_scope,
          tags: shopify_prod.tags,
          template_suffix: shopify_prod.template_suffix,
          title: shopify_prod.title,
          updated_at: shopify_prod.updated_at,
          vendor: shopify_prod.vendor
        )
        if shopify_prod.images.size > 0
          prod = Product.find(shopify_prod.id)
          shopify_prod.images.each do |shopify_image|
            prod.images.create(
              id: shopify_image.id,
              created_at: shopify_image.created_at,
              position: shopify_image.position,
              src: shopify_image.src,
              width: shopify_image.width,
              height: shopify_image.height,
              updated_at: shopify_image.updated_at
            )
          end
        end
      end
    end
  end
end
