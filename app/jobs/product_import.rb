class ProductImport
  @queue = :product
  def self.perform
    #initialize class and run pull
    ShopifyAPI::Products.first
  end
end
