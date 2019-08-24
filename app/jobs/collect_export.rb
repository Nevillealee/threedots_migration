class CollectExport
  include HTTParty
  @queue = :collect
  base_uri  ENV['STAGING_BASE_URI']

  def self.perform
    start = Time.now
    Resque.logger = ::Logger.new("#{Rails.root}/log/collect_export.log")
    Resque.logger.info 'COLLECT EXPORT Job starts'
    collects = Collect.all
    
    Resque.logger.info "Runtime: #{Time.now - start} seconds"
  end
end
