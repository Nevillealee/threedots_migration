require 'resque/tasks'
task 'resque:setup' => :environment


namespace :import do
  desc 'import threedots active products/product images'
  task 'products' => :environment do
    Resque.enqueue(ProductImport)
  end

  desc 'import threedots active custom collections'
  task 'custom_collections' => :environment do
    Resque.enqueue(CustomCollectionImport)
  end

  desc 'import threedots active collects'
  task 'collects' => :environment do
    Resque.enqueue(CollectImport)
  end

  desc 'import threedots active pages'
  task 'pages' => :environment do
    Resque.enqueue(PageImport)
  end

  # desc 'import threedots active variants/inventory'
  # task 'variants' => :environment do
  #   Resque.enqueue(ProductImport)
  # end

  desc 'import threedots inventory'
  task 'inventory' => :environment do
    Resque.enqueue(InventoryImport)
  end

  desc 'import threedots metafields [products, collections, product_images, or variants]'
  task 'metafield', [:type] do |t, args|
    # args.type = argument passed in
    # args.type.class = String
    Resque.enqueue(MetafieldImport, *args)
  end
end

namespace :export do
  desc 'export to staging threedots products/variants/images'
  task 'staging_products' => :environment do
    Resque.enqueue(ProductExport)
  end

  desc 'export to staging, custom collections'
  task 'custom_collections' => :environment do
    Resque.enqueue(CustomCollectionExport)
  end

  desc 'export to staging, collects'
  task 'collects' => :environment do
    Resque.enqueue(CollectExport)
  end

  desc 'export to staging, inventory'
  task 'inventory' => :environment do
    Resque.enqueue(InventoryExport)
  end

  desc 'export to staging, pages'
  task 'pages' => :environment do
    Resque.enqueue(PageExport)
  end
end
