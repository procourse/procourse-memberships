module ::DiscourseLeague
  class TransactionSerializer < ApplicationSerializer

    attributes :id, 
    :product_name, 
    :transaction_id, 
    :transaction_amount, 
    :transaction_date,
    :billing_address,
    :credit_card,
    :paypal

    def product_name
      products = PluginStore.get("discourse_league", "levels") || []
      product = products.select{|level| level[:id] == object.product_id.to_i}
      if !product.empty?
        product[0][:name]
      end
    end

  end
end