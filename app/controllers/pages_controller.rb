class PagesController < ApplicationController
  def home
    redirect_to dashboard_path if logged_in?
  end

  def dashboard

    @total_balance = 0
    @symbols = Transaction.where(user_id: current_user.id).select(:symbol).distinct.pluck(:symbol)

    @data = @symbols.map do |symbol|
      transactions = Transaction.where(user_id: current_user.id).for_symbol(symbol)

      token_current_price = get_current_price(symbol)
      token_average_buy_price = Transaction.average_buy_price(transactions)
      token_average_sell_price = Transaction.average_sell_price(transactions)
      token_balance = Transaction.balance(transactions)

      if Float(token_current_price, exception: false) && Float(token_average_buy_price, exception: false)
        token_current_price = token_current_price
        token_balance_in_dollars = token_balance * token_current_price
        token_potential_profits = token_balance * (token_current_price - token_average_buy_price)
        @total_balance += token_balance_in_dollars
      else
        token_balance_in_dollars = nil
        token_potential_profits = nil
      end

      {
        symbol: symbol,
        current_price: token_current_price,
        average_buy_price: token_average_buy_price,
        average_sell_price: token_average_sell_price,
        balance: token_balance,
        balance_in_dollars: token_balance_in_dollars,
        potential_profits: token_potential_profits
      }
    end

    @data.delete_if { |token| token[:balance_in_dollars] == nil || token[:balance_in_dollars] <= 0 }
    @data.sort_by! { |token| token[:balance_in_dollars] }.reverse!

    @data.each do |token|
      Rails.logger.info "CURRENT_PRICE: #{token[:symbol]}: #{token[:current_price].class}"

      if Float(token[:current_price], exception: false) && Float(token[:balance], exception: false)
        token[:portfolio_percentage] = ((token[:balance] * token[:current_price]) / @total_balance) * 100
      else
        token[:portfolio_percentage] = nil
      end
    end
  end

  private

    def get_current_price(symbol)
      service = CoinloreService.new
      current_price = service.get_current_price_by_symbol(symbol)

      return current_price
    end
end
