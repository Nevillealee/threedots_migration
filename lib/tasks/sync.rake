require 'resque/tasks'
task 'resque:setup' => :environment


desc 'import threedots active products'
task 'import_product' => :environment do
  Resque.enqueue(ProductImport)
end
