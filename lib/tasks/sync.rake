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

  desc 'import threedots inventory'
  task 'inventory' => :environment do
    Resque.enqueue(InventoryImport)
  end
end
