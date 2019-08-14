class Metafield < ApplicationRecord
  belongs_to :owner, polymorphic: true #mirrors https://help.shopify.com/en/api/reference/metafield
end
