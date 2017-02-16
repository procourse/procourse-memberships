module ::DiscourseLeague
  class TransactionSerializer < ApplicationSerializer

    attributes :id, 
    :product_name, 
    :transaction_id, 
    :transaction_amount, 
    :transaction_date

    def product_name
      products = PluginStore.get("discourse_league", "levels") || []
      product = products.select{|level| level[:id] == object.product_id.to_i} if !products.empty?
      product[0][:name]
    end

  end
end