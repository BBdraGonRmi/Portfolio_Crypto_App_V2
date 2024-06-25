class PagesController < ApplicationController
  def home
    redirect_to dashboard_path if logged_in?
  end

  def dashboard

    @total_balance = Transaction.where(user_id: current_user.id).sum(:total_value)

    @symbols = Transaction.where(user_id: current_user.id).select(:symbol).distinct.pluck(:symbol)
    @data = @symbols.map do |symbol|
      transactions = Transaction.where(user_id: current_user.id).for_symbol(symbol)
      {
        symbol: symbol,
        average_buy_price: Transaction.average_buy_price(transactions),
        average_sell_price: Transaction.average_sell_price(transactions),
        balance: Transaction.balance(transactions),
        balance_in_dollars: Transaction.balance_in_dollars(transactions, get_current_price(symbol))
      }
    end
  end

  private

    def get_current_price(symbol)
      # Implement a method to get the current price of the symbol
      # This could be a call to an external API or a value from your database
      # For now, let's just return a dummy value
      3400.0
    end
end
