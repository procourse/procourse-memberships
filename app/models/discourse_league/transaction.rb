module ::DiscourseLeague
  class Transaction
    alias :read_attribute_for_serialization :send

    attr_accessor :id, :user_id, :product_id, :transaction_id, :transaction_amount, :transaction_date

    def initialize(opts={})
      @id = opts[:id]
      @user_id = opts[:user_id]
      @product_id = opts[:product_id]
      @transaction_id = opts[:transaction_id]
      @transaction_amount = opts[:transaction_amount]
      @transaction_date = opts[:transaction_date]
    end

  end
end