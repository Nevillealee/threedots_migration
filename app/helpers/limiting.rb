module Limiting
  def throttle_check
    return if ShopifyAPI.credit_left > 5
    sleep_time = (38 - ShopifyAPI.credit_left)/2
    Resque.logger.debug "api limit reached, sleeping #{sleep_time}"
    sleep sleep_time
  end
end
