require 'net/http'
require 'json'

class CoingeckoService
  BASE_URI = 'https://api.coingecko.com/api/v3'

  def fetch_coins_list
    Rails.cache.fetch('coingecko_coins_list', expires_in: 12.hours) do
      uri = URI("#{BASE_URI}/coins/list")
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        []
      end
    end
  end

  def coins_by_symbol(symbol)
    coins = fetch_coins_list
    coins.select { |c| c['symbol'] == symbol.downcase }
  end

  def fetch_price_by_symbol(symbol)
    coin_id = symbol_to_id(symbol)
    return nil unless coin_id

    uri = URI("#{BASE_URI}/simple/price")
    uri.query = URI.encode_www_form(ids: coin_id, vs_currencies: 'usd')

    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      #Rails.logger.info "Data fetched: #{data}"
      #data[coin_id]['usd']
    else
      nil
    end
  end
end
