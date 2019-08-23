class ImageExport
  include HTTParty
  @queue = :staging_image
  base_uri  ENV['STAGING_BASE_URI']
  def self.perform
    start = Time.now
    Resque.logger = ::Logger.new("#{Rails.root}/log/image_export.log")
    Resque.logger.info 'IMAGE EXPORT Job starts'
  end
end
