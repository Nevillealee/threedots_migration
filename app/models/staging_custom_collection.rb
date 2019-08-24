class StagingCustomCollection < ApplicationRecord
  has_many :staging_collects
  has_many :staging_products, through: :staging_collects
end
