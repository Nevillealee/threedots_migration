class MetafieldImport
  @queue = :metafield
  extend Limiting
  def self.perform(type)
    # type is String = products, collections, variants, or product_images
    Resque.logger = Logger.new("#{Rails.root}/log/metafield_#{type}_import.log")
    Resque.logger.level = Logger::DEBUG
    Resque.logger.info "#{type} Metafield IMPORT Job start"

  end
end
