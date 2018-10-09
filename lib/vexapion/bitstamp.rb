# coding: utf-8

# Bitstamp API Ver 2 対応版
# 2018/2/21現在

require 'vexapion'
require 'json'

#@author @fuyuton fuyuton@pastelpink.sakura.ne.jp
module Vexapion

	# bitstampのAPIラッパークラスです。
	# 各メソッドの戻り値は下記URLを参照してください。
	# @see 

	class Bitstamp < BaseExchanges
		
		#@api private
		def initialize(key = nil, secret = nil, customer_id = nil)
			super(key,secret)

			@customer_id = customer_id
			@public_url = 'https://www.bitstamp.net/api/'
			@private_url = 'https://www.bitstamp.net/api/'
		end

# Public API

		# @raise RequestFailed APIリクエストの失敗
		# @raise RetryException  リクエストの結果が確認できないとき 408, 500, 502, 503
		# @raise Warning APIレベルでのエラー(レスポンスのsuccess: 0の時)
		# @raise Error  クライアントエラー 400, 401, 403
		# @raise Fatal APIラッパーの修正が必要と思われるエラー, 404


		# ティッカー
		# @param [String] pair 取得したい通貨ペア
		# @return [Hash]
		def ticker(pair:nil)
			method = "ticker"
			get("v2/#{method}/#{pair.nil? ? '' : pair}")
		end

		# hourlyティッカー
		# @param [String] pair 取得したい通貨ペア
		# @return [Hash]
		def ticker_hour(pair:nil)
			method = 'ticker_hour'
			get("v2/#{method}/#{pair.nil? ? '' : pair}")
		end

		# 板情報(order_book)
		# @param [String] pair 取得したい通貨ペア
		# @return [Hash]
		def order_book(pair:)
			method = 'order_book'
			get("v2/#{method}/#{pair}")
		end

		# 取引履歴
		# @param [String] pair 取得したい通貨ペア
		# @return [Array]
		def transactions(pair:, time:nil)
			method = 'transactions'
			get("v2/#{method}/#{pair}")
		end

		# 利用可能な通貨ペアの取得
		# @param [String] pair 取得したい通貨ペア(ただしすべて取得したいときは'all')
		# @return [Array]
		def trading_pairs_info
			get('v2/trading-pairs-info')
		end

		# EUR/USD conversion rate
		# @return [Array]
		def eur_usd
			get('eur_usd')
		end

# Private API

		# 現在の残高を取得します
		# @return [Hash]
		def account_balance
			post("v2/balance")
		end

		# 自分の取引履歴を取得します
		# @param [String]    pair   				取得したい通貨ペア。省略時はすべての通貨ペア
		# @param [Integer]   offset					Skip that many transactions before returning results(default: 0)
		# @param [Integer]   limit					Limit result to that many transactions (default: 100; max: 1000)
		# @param [String]    sort						Sorting by date and time: asc - ascending; desc - descending(default: desc)
		# @return [Hash]
		def user_transactions(pair:nil, offset: 0, limit: 100, sort: "desc")
			method = "v2/user_transactions/#{pair.nil? ? '' : pair}"
			params = {
				offset:	offset,
				limit: limit,
				sort: sort
			}

			post(method, params)
		end

		# Open orders
		# @param
		def open_orders(pair: nil)
			method = "v2/open_orders/#{pair.nil? ? 'all' : pair }/"

			post(method)
		end

		# Order status
		def order_status(id:)
			method = "order_status"

			post(method, id: id)
		end

		# Cancel order
		def cancel_order(id:)
			method = "v2/cancel_order"

			post(method, id: id)
		end

		# Cancel all orders
		def cancel_all_orders
			method = "cancel_all_orders"

			post(method)
		end

		#buy limit order
		# @param [string] pair
		# @param [float] price
		# @param [float] amount
		# @param [float] limit_price
		# @param [bool] daily_order true/false
		# @param [bool] ioc_order true/false
		#def buy_limit_order(pair:, price:, amount:, limit_price: nil, daily_order: false, ioc_order: false)
		def buy_limit_order(pair:, price:, amount:, limit_price: nil, daily_order: nil, ioc_order: nil)
			method = "v2/buy/#{pair}"
			params = {
				price: price,
        amount: amount,
				limit_price: limit_price,
				daily_order: daily_order,
				ioc_order: ioc_order
			}

			post(method, params)
		end

		#buy market order
		# @param [string] pair
		# @param [float] amount
		def buy_market_order(pair:, amount:)
			method = "v2/buy/market/#{pair}"
			params = {
				price: price
			}

			post(method, params)
		end


		#sell limit order
		# @param [string] pair
		# @param [float] price
		# @param [float] amount
		# @param [float] limit_price
		# @param [bool] daily_order true/false
		# @param [bool] ioc_order true/false
		#def sell_limit_order(pair:, price:, amount:, limit_price: nil, daily_order: false, ioc_order: false)
		def sell_limit_order(pair:, price:, amount:, limit_price: nil, daily_order: nil, ioc_order: nil)
			method = "v2/sell/#{pair}"
			params = {
				price: price,
        amount: amount,
				limit_price: limit_price,
				daily_order: daily_order,
				ioc_order: ioc_order
			}

			post(method, params)
		end

		#sell market order
		# @param [string] pair
		# @param [float] amount
		def sell_market_order(pair:, amount:)
			method = "v2/sell/market/#{pair}"
			params = {
				price: price
			}

			post(method, params)
		end

		# Withdrawal requests
		def withdrawal_requests(timedelta: nil)
			method = "v2/withdrawal-requests"
			params = { timedelta: timedelta }

			post(method, params)
		end

		# Bitcoin withdrawal
		# @param [float] amount
		# @param [String] address
		# @param [bool] instant 0(false)/1(true)
		def bitcoin_withdrawal(amount:, address:, instant:0)
			method = "bitcoin_withdrawal"
			params = {
				amount: amount,
				address: address,
				instant: instant
			}

			post(method, params)
		end


## altcoin withdrawal & get deposit address

		# *coin withdrawal
		# @param [float] amount
		# @param [String] address
		def altcoin_withdrawal(currency:, amount:, address:)
			method = "v2/#{currency}_withdrawal"
			params = {
				amount: amount,
				address: address,
			}

			post(method, params)
		end

		# *coin deposit address
		# @param [String] currency ltc/eth/xrp/bch
		def altcoin_deposit_address(currency: )
			method = "v2/#{currency}_address"

			post(method)
		end

		# Unconfirmed bitcoin deposits
		def unconfirmed_btc
			method = "unconfirmed_btc"

			post(method)
		end

		# Transfer balance from Sub to Main account
		def transfer_to_main(currency:, amount:, sub_account:nil)
			method = "v2/transfer-to-main"
			params = {
				amount: amount,
				subAccount: sub_account
			}

			post(method, params)
		end

		# Transfer balance from Main to sub account
		def transfer_from_main(currency:, amount:, sub_account:nil)
			method = "v2/transfer-from-main"
			params = {
				amount: amount,
				subAccount: sub_account
			}

			post(method, params)
		end
		
		# Open bank withdrawal
		# @param [Float] amount
		# @param [String] currency account_currency
		# @param [String] name
		# @param [String] iban
		# @param [String] bic
		# @param [String] address
		# @param [String] postal_code
		# @param [String] city
		# @param [String] country
		# @param [String] type
		# @param [Hash] bank_data the options to create a message with. (only type: international)
		# @option bank_data [String] name
		# @option bank_data [String] address
		# @option bank_data [String] postal_code
		# @option bank_data [String] city
		# @option bank_data [String] country
		# @option bank_data [String] currency
		# @param [String] comment
		def bank_withdrawal( amount:, currency:, name:, iban:, bic:, address:, postal_code:, city:, country:, type:,
				bank_data: nil, comment: nil)
			method = 'v2/withdrawal/open/'
			
			params = {
				amount: amount, account_currency: currency,
				name: name, IBAN: iban,
				BIC: bic, address: address,
				postal_code: postal_code, city: city,
				country: country, type: type,
			}
		
			unless bank_data.nil?
				params[:bank_name] = bank_data['name']
				params[:bank_address] = bank_data['address']
				params[:bank_postal_code] = bank_data['postal_code']
				params[:bank_city] = bank_data['city']
				params[:bank_country] = bank_data['country']
				params[:currency] = bank_data['currency']
			end
			params[:comment] = comment unless comment.nil?

			post(method, params)
		end

		# Bank withdrawal status
		def bank_withdrawal_status(id: )
			method = 'v2/withdrawal/status/'
			
			post(method, id: id)
		end

		# Cancel bank withdrawal
		def cancel_bank_withdrawal(id: )
			method = 'v2/withdrawal/cancel/'
			
			post(method, id: id)
		end

		# New liquidation address
		def create_liquidation_address(currency:)
			method = 'v2/liquidation_address/new/'

			post(method, liquidation_currency: currency)
		end

		# Liquidation address info
		def liquidation_address_info(address: nil)
			method = 'v2/liquidation_address/info/'

			post(method, address: address)
		end



#  Create request header & body

		private 
		
		#@api private
		def get(method, param=nil)
			url = "#{@public_url}#{method.downcase}/"
			uri = URI.parse url
			#puts "URL:#{url}"
			request = Net::HTTP::Get.new(uri.request_uri)

			do_command(uri, request)
		end

		#@api private
		def post(method, params = {})
			url = "#{@private_url}#{method.downcase}/"
			uri = URI.parse url
			nonce = get_nonce

			params['key'] = @key
			params['signature'] = signature("#{nonce}#{@customer_id}#{@key}")
			params['nonce'] = nonce

			request = Net::HTTP::Post.new(uri)
			request.set_form_data(params)  #クエリをURLエンコード (p1=v1&p2=v2...)

      begin 
			  res = do_command(uri, request)
      rescue Vexapion::HTTPError => e
		    #p e.http_status_code
		    #p e.message
        r = JSON.parse(e.body)
        #puts JSON.pretty_generate(r)
			  error_check(r)
      end
			res
		end

		#@api private
		def signature(message)
			algo = OpenSSL::Digest.new('sha256')
			OpenSSL::HMAC.hexdigest(algo, @secret, message).upcase
		end

		#@api private
		def error_check(res)
      #API Error
      if res.is_a?(Hash) && res.has_key?('status') && res['status'] =~ /error/
		    puts "error code: #{res['code']}, reason: #{res['reason']}"
      end
			#if res.is_a?(Hash) && res.has_key?('error')
			#	raise Warning.new('0', res['error'])
			#end
		end

	end #of class
end #of Vexapion module
