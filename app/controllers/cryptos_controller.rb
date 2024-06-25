class CryptosController < ApplicationController

  def show_price
    token_symbol = params[:symbol].downcase
    service = CoingeckoService.new
    coins = service.coins_by_symbol(token_symbol)

    if coins.size == 1
      price = service.fetch_price_by_id(coins.first['id'])
      if price
        render json: { token: token_symbol, price: price }
      else
        render json: { error: 'Price not found' }, status: :not_found
      end
    elsif coins.size > 1
      render json: { error: 'Multiple coins found', coins: coins }, status: :multiple_choices
    else
      render json: { error: 'Coin not found' }, status: :not_found
    end
  end

  def show_coins_list
    service = CoingeckoService.new
    list = service.fetch_coins_list

    if list
      render json: list
    else
      render json: { error: 'Coins list not found' }, status: :not_found
    end
  end

  def show_price_by_id
    coin_id = params[:id]
    service = CoingeckoService.new
    price = service.fetch_price_by_id(coin_id)

    if price
      render json: { coin_id: coin_id, price: price }
    else
      render json: { error: 'Price not found' }, status: :not_found
    end
  end
end
