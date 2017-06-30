module ::DiscourseLeague
  class Subscription
    alias :read_attribute_for_serialization :send

    attr_accessor :id, :user_id, :product_id, :subscription_id, :subscription_end_date, :created_at, :active

    def initialize(opts={})
      @id = opts[:id]
      @user_id = opts[:user_id]
      @product_id = opts[:product_id]
      @subscription_id = opts[:subscription_id]
      @subscription_end_date = opts[:subscription_end_date]
      @created_at = opts[:created_at]
      @active = opts[:active]
    end

  end
end