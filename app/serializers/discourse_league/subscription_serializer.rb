module ::DiscourseLeague
  class SubscriptionSerializer < ApplicationSerializer

    attributes :id,
     :product,
     :subscription_id,
     :subscription_end_date,
     :created_at,
     :active

    def product
      products = PluginStore.get("discourse_league", "levels") || []
      product = products.select{|level| level[:id] == object.product_id.to_i} if !products.empty?
      product[0]
    end

  end
end