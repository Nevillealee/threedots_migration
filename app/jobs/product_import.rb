class ProductImport
  @queue = :product
  extend Limiting
  def self.perform
    Resque.logger = Logger.new("#{Rails.root}/log/product_variant_image_import.log")
     Resque.logger.level = Logger::DEBUG
     Resque.logger.info 'PRODUCT IMPORT Job starts'
    #initialize class and run pull
    count = ShopifyAPI::Product.find(:count)
    Resque.logger.info "products to process: #{count.count}"
    pages = count.count.to_i % 250
    start = Time.now
    1.upto(pages) do |page|
      throttle_check
      products = ShopifyAPI::Product.find(:all, params: {limit: 250, page: page})
      products.each do |shopify_prod|
        Resque.logger.info "Product_ID: #{shopify_prod.id}, title: #{shopify_prod.title}"
      begin
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
        prod = Product.find(shopify_prod.id)
      rescue StandardError => e
        Resque.logger.error "Product(id: #{shopify_prod.id}) table error: #{e}"
        next
      end
        if shopify_prod.images.size > 0
          Resque.logger.info "    Images to process: #{shopify_prod.images.size}"
          shopify_prod.images.each do |shopify_image|
          begin
            img = prod.images.find_by_id(shopify_image.id)
            if img
              img.update(
                created_at: shopify_image.created_at,
                position: shopify_image.position,
                variant_ids: shopify_image.variant_ids,
                src: shopify_image.src,
                width: shopify_image.width,
                height: shopify_image.height,
                updated_at: shopify_image.updated_at
              )
            else
              prod.images.create(
                id: shopify_image.id,
                created_at: shopify_image.created_at,
                position: shopify_image.position,
                variant_ids: shopify_image.variant_ids,
                src: shopify_image.src,
                width: shopify_image.width,
                height: shopify_image.height,
                updated_at: shopify_image.updated_at
              )
            end
          rescue StandardError => e
            Resque.logger.error "Image(id: #{shopify_image.id}) table error: #{e}"
            next
          end #end of rescue block
          end
        end
        next unless shopify_prod.variants.size > 0
        Resque.logger.info "    Variants to process: #{shopify_prod.variants.size}"
        shopify_prod.variants.each do |variant|
        begin
          vari = Variant.find_by_id(variant.id)
          if vari
            vari.update(
              barcode: variant.barcode,
              compare_at_price: variant.compare_at_price,
              created_at: variant.created_at,
              fulfillment_service: variant.fulfillment_service,
              grams: variant.grams,
              image_id: variant.image_id,
              inventory_item_id: variant.inventory_item_id,
              inventory_management: variant.inventory_management,
              inventory_policy: variant.inventory_policy,
              inventory_quantity: variant.inventory_quantity,
              option1: variant.option1,
              option2: variant.option2,
              option3: variant.option3,
              position: variant.position,
              price: variant.price,
              sku: variant.sku,
              taxable: variant.taxable,
              title: variant.title,
              updated_at: variant.updated_at,
              weight: variant.weight,
              weight_unit: variant.weight_unit
            )
          else
            prod.variants.create(
              id: variant.id,
              barcode: variant.barcode,
              compare_at_price: variant.compare_at_price,
              created_at: variant.created_at,
              fulfillment_service: variant.fulfillment_service,
              grams: variant.grams,
              image_id: variant.image_id,
              inventory_item_id: variant.inventory_item_id,
              inventory_management: variant.inventory_management,
              inventory_policy: variant.inventory_policy,
              inventory_quantity: variant.inventory_quantity,
              option1: variant.option1,
              option2: variant.option2,
              option3: variant.option3,
              position: variant.position,
              price: variant.price,
              sku: variant.sku,
              taxable: variant.taxable,
              title: variant.title,
              updated_at: variant.updated_at,
              weight: variant.weight,
              weight_unit: variant.weight_unit
            )
          end
        rescue StandardError => e
          Resque.logger.error "Variant(id: #{variant.id}) table error: #{e}"
          next
        end #end of rescue block
        end
      end

    end
    Resque.logger.info "Done, Runtime: #{Time.now - start} seconds"
  end
end
