module DiscourseLeague
  class TransactionsController < ApplicationController

    def all
      if current_user.id == params[:user_id].to_i
        transactions = PluginStore.get("discourse_league", "t:" + params[:user_id].to_s) || []

        if !transactions.empty?
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
        transactions = PluginStore.get("discourse_league", "t:" + params[:user_id].to_s) || []

        if transactions.empty?
          render_json_error(params[:user_id])
        else
          transaction = transactions.select{|transaction| transaction[:transaction_id] == params[:id]}
          
          if !transaction.empty?
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