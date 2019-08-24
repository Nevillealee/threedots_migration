class StagingCollect < ApplicationRecord
  belongs_to :staging_custom_collection, optional: true
  belongs_to :staging_product, optional: true
end
