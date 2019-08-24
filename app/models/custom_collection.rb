class CustomCollection < ApplicationRecord
  has_many :collects
  has_many :products, through: :collects
  has_many :metafields, as: :owner

  def get_staging
    StagingCustomCollection.find_by_handle(handle)
  end
end
