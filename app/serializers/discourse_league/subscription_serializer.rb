module ::DiscourseLeague
  class SubscriptionSerializer < ApplicationSerializer

    attributes :id,
     :product_name,
     :subscription_id,
     :created_at,
     :active

    def product_name
      products = PluginStore.get("discourse_league", "levels") || []
      product = products.select{|level| level[:id] == object.product_id.to_i} if !products.empty?
      product[0][:name]
    end

  end
end