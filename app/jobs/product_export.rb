# exports product, variant, and image at once
class ProductExport
  include HTTParty
  @queue = :staging_product
  base_uri  ENV['STAGING_BASE_URI']

  def self.perform
    start = Time.now
    Resque.logger = ::Logger.new("#{Rails.root}/log/product_variant_image_export.log")
    Resque.logger.info 'PRODUCT EXPORT Job starts'
    # collect all active products that arent in staging_table
    active_products = Product.joins("LEFT JOIN staging_products ON products.handle = staging_products.handle").where("staging_products.handle": nil)
    if active_products.size > 0
      active_products.each do |active_prod|
        my_body = format_prod_body(active_prod)
        options = { body: my_body }
        res = post("#{base_uri}/#{ENV['API_VERSION']}/products.json", options)

        Resque.logger.info res.parsed_response
        call_limit = res.headers['x-shopify-shop-api-call-limit']

        if call_limit.to_i > 35
          Resque.logger.debug "CALL LIMIT REACHED: #{call_limit}, sleeping 15"
          sleep 15
        end

        if res.code == 201 || res.code == 200
          create_local(res.parsed_response['product'])
        else
          Resque.logger.warn "FAILURE!!!!! HTTP CODE: #{res.code}"
        end

        Resque.logger.info "HTTP RESPONSE CODE: #{res.code}"
        Resque.logger.info "------------> x-shopify-shop-api-call-limit: #{call_limit}\n\n"
      end
    else
      Resque.logger.info "No products were updated"
    end
    Resque.logger.info "Runtime: #{Time.now - start} seconds"
  end

  def self.format_prod_body(prod)
    my_variants = []
    my_options = []
    my_images = []

    if prod.variants
      prod.variants.each do |vrnt|
        v_body = {
          barcode: vrnt.barcode,
          compare_at_price: vrnt.compare_at_price,
          fulfillment_service: vrnt.fulfillment_service,
          grams: vrnt.grams,
          inventory_policy: vrnt.inventory_policy,
          sku: vrnt.sku,
          option1: vrnt.option1,
          option2: vrnt.option2,
          option3: vrnt.option3,
          price: vrnt.price,
          taxable: vrnt.taxable,
          title: vrnt.title,
          weight: vrnt.weight,
          weight_unit: vrnt.weight_unit
        }
        my_variants << v_body
      end
    end

    if prod.options
      option_array = JSON.parse(prod.options)
      option_array.each do |opt|
        opt_hash = {
          name: opt['name'],
          values: opt['values']
        }
        my_options << opt_hash
      end
    end

    if prod.images
      prod.images.each do |img|
        img_body = {
          src: img.src
        }
        my_images << img_body
      end
    end

    return {
      product: {
        title: prod.title,
        handle: prod.handle,
        body_html: prod.body_html,
        variants: my_variants,
        options: my_options,
        images: my_images,
        product_type: prod.product_type,
        published_scope: prod.published_scope,
        tags: prod.tags,
        template_suffix: prod.template_suffix,
        vendor: prod.vendor
      }
    }
  end

  def self.create_local(stage_prod)
    StagingProduct.upsert(
      id: stage_prod['id'],
      body_html: stage_prod['body_html'],
      handle: stage_prod['handle'],
      created_at: stage_prod['created_at'],
      options: stage_prod['options'],
      product_type: stage_prod['product_type'],
      published_at: stage_prod['published_at'],
      published_scope: stage_prod['published_scope'],
      tags: stage_prod['tags'],
      template_suffix: stage_prod['template_suffix'],
      title: stage_prod['title'],
      updated_at: stage_prod['updated_at'],
      vendor: stage_prod['vendor']
    )
    s_prod = StagingProduct.find(stage_prod['id'])

    if stage_prod['images'].size > 0
      stage_prod['images'].each do |stage_img|
      begin
        s_img = StagingImage.find_by_id(stage_img['id'])
        if s_img
          s_img.update(
            created_at: stage_img['created_at'],
            position: stage_img['position'],
            variant_ids: stage_img['variant_ids'],
            src: stage_img['src'],
            width: stage_img['width'],
            height: stage_img['height'],
            updated_at: stage_img['updated_at']
          )
        else
          StagingImage.create(
            id: stage_img['id'],
            created_at: stage_img['created_at'],
            position: stage_img['position'],
            variant_ids: stage_img['variant_ids'],
            src: stage_img['src'],
            width: stage_img['width'],
            height: stage_img['height'],
            updated_at: stage_img['updated_at']
          )
        end
      rescue StandardError => e
        Resque.logger.error "StagingImage(id: #{stage_img['id']}) table error: #{e}"
        next
      end #end of rescue block
      end
    end

    if stage_prod['variants'].size > 0
      stage_prod['variants'].each do |s_variant|
        s_vari = StagingVariant.find_by_id(s_variant['id'])
        begin
          if s_vari
            s_vari.update(
              barcode: s_variant['barcode'],
              compare_at_price: s_variant['compare_at_price'],
              created_at: s_variant['created_at'],
              fulfillment_service: s_variant['fulfillment_service'],
              grams: s_variant['grams'],
              image_id: s_variant['image_id'],
              inventory_item_id: s_variant['inventory_item_id'],
              inventory_management: s_variant['inventory_management'],
              inventory_policy: s_variant['inventory_policy'],
              inventory_quantity: s_variant['inventory_quantity'],
              option1: s_variant['option1'],
              option2: s_variant['option2'],
              option3: s_variant['option3'],
              position: s_variant['position'],
              price: s_variant['price'],
              sku: s_variant['sku'],
              taxable: s_variant['taxable'],
              title: s_variant['title'],
              updated_at: s_variant['updated_at'],
              weight: s_variant['weight'],
              weight_unit: s_variant['weight_unit']
            )
          else
            s_prod.staging_variants.create(
              id: s_variant['id'],
              barcode: s_variant['barcode'],
              compare_at_price: s_variant['compare_at_price'],
              created_at: s_variant['created_at'],
              fulfillment_service: s_variant['fulfillment_service'],
              grams: s_variant['grams'],
              image_id: s_variant['image_id'],
              inventory_item_id: s_variant['inventory_item_id'],
              inventory_management: s_variant['inventory_management'],
              inventory_policy: s_variant['inventory_policy'],
              inventory_quantity: s_variant['inventory_quantity'],
              option1: s_variant['option1'],
              option2: s_variant['option2'],
              option3: s_variant['option3'],
              position: s_variant['position'],
              price: s_variant['price'],
              sku: s_variant['sku'],
              taxable: s_variant['taxable'],
              title: s_variant['title'],
              updated_at: s_variant['updated_at'],
              weight: s_variant['weight'],
              weight_unit: s_variant['weight_unit']
            )
          end
        rescue StandardError => e
          Resque.logger.error "StagingVariant(id: #{s_variant['id']}) table error: #{e}"
          next
        end #end of rescue block
      end
    end

    Resque.logger.info "Staging Product(variants/images)(#{stage_prod['title']}) saved to local DB!"
  end
end
