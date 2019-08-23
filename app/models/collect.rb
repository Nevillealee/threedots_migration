class Collect < ApplicationRecord
  belongs_to :custom_collection, optional: true
  belongs_to :product, optional: true
end
