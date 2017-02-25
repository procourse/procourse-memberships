module DiscourseLeague
  class TransactionsController < ApplicationController

    def all
      if current_user.id == params[:user_id].to_i
        transactions = PluginStore.get("discourse_league", "transactions")

        if !transactions.nil?
          transactions = transactions.select{|transaction| transaction[:user_id] == params[:user_id].to_i}
          transactions = transactions.flatten.map{|transaction| Transaction.new(transaction)} if !transactions.empty?
        else
          transactions = []
        end
        render_json_dump(serialize_data(transactions, TransactionSerializer))
      else
        render_json_error(params[:user_id])
      end
    end

    def show
      if current_user.id == params[:user_id].to_i
        transactions = PluginStore.get("discourse_league", "transactions") || []

        if transactions.empty?
          render_json_error(params[:user_id])
        else
          transaction = transactions.select{|transaction| transaction[:id] == params[:id].to_i}
          if !transaction.empty? && transaction[0][:user_id] == params[:user_id].to_i
            transaction = transaction.flatten.map{|transaction| Transaction.new(transaction)}
            render_json_dump(serialize_data(transaction[0], TransactionSerializer))
          else
            render_json_error(params[:user_id])
          end
        end
      else
        render_json_error(params[:user_id])
      end
    end

  end
end