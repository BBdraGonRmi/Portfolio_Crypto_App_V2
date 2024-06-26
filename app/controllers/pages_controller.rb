class PagesController < ApplicationController
  def home
    redirect_to dashboard_path if logged_in?
  end

  def dashboard
    @bitcoin_data = {
      "2023-06-01" => 1000,
      "2023-07-01" => 1500,
      "2023-08-01" => 1200,
      "2023-09-01" => 1700,
      "2023-10-01" => 1400,
      "2023-11-01" => 1800
    }

    @ethereum_data = {
      "2020-12-01" => 900,
      "2021-01-01" => 1300,
      "2021-02-01" => 1100,
      "2021-03-01" => 1600
    }

    @deposits = Transaction.where(user_id: current_user.id, operation: "DEPOSIT").order(:datetime_of_transaction)
    @deposits_data = {}
    net_value = 0

    @deposits.each do |transaction|
      Rails.logger.info "DEPOSITS: #{transaction.net_value}"
      net_value += transaction.net_value
      #Rails.logger.info "NET VALUE: #{net_value}"
      date = transaction.datetime_of_transaction.to_date
      @deposits_data[date] = net_value
    end

    #fill_missing_months_with_last_value(@deposits, @deposits_data)

    @monthly_deposits_data = {}
    @deposits_data.each do |date, net_value|
      month_start = date.beginning_of_month
      @monthly_deposits_data[month_start] = net_value
    end

    @transactions = Transaction.where(user_id: current_user.id).order(:datetime_of_transaction)
    @transactions_data = {}
    net_value = 0

    @transactions.each do |transaction|
      net_value += transaction.net_value
      #Rails.logger.info "NET VALUE: #{net_value}"
      date = transaction.datetime_of_transaction.to_date
      @transactions_data[date] = net_value
    end

    #fill_missing_months_with_last_value(@transactions, @transactions_data)

    @monthly_transactions_data = {}
    @transactions_data.each do |date, net_value|
      month_start = date.beginning_of_month
      @monthly_transactions_data[month_start] = net_value
    end


    @total_balance = 0
    @symbols = Transaction.where(user_id: current_user.id).select(:symbol).distinct.pluck(:symbol)

    @tokens_data = @symbols.map do |symbol|
      transactions = Transaction.where(user_id: current_user.id).for_symbol(symbol)

      token_current_price = get_current_price(symbol)
      token_average_buy_price = Transaction.average_buy_price(transactions)
      token_average_sell_price = Transaction.average_sell_price(transactions)
      token_balance = Transaction.balance(transactions)

      if Float(token_current_price, exception: false)
        token_current_price = token_current_price.to_f
        token_balance_in_dollars = token_balance * token_current_price
        token_potential_profits = token_balance * (token_current_price - token_average_buy_price.to_f)
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

    @tokens_data.each do |token|

      if Float(token[:current_price], exception: false)
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

    def fill_missing_months_with_last_value(transactions, transactions_data)
      return if transactions.empty?

      current_value = 0
      last_known_date = nil

      transactions.each do |transaction|
        current_value += transaction.net_value
        date = transaction.datetime_of_transaction.to_date

        # Fill missing months with last known value
        if last_known_date && date > last_known_date
          (last_known_date + 1.month..date.prev_month).each do |missing_date|
            transactions_data[missing_date] = current_value
          end
        end

        transactions_data[date] = current_value
        last_known_date = date
      end
    end
end
