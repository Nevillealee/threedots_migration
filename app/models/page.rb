class Page < ApplicationRecord
  has_many :metafields, as: :owner
end
