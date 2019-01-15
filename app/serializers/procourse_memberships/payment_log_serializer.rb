module ::ProcourseMemberships
    class PaymentLogSerializer < ApplicationSerializer
  
      attributes :id,
       :product_name,
       :timestamp,
       :username,
       :level_id,
       :type,
       :amount
  
      def product_name
        products = PluginStore.get("procourse_memberships", "levels") || []
        product = products.select{|level| level[:id] == object.level_id.to_i} if !products.empty?
        if !product.empty?
            product[0][:name]
        end
      end
    end
  end