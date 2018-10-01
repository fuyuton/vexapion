# coding: utf-8

# Binance API
# 2018/3/2現在

require 'date'
require 'vexapion'

#@author @fuyuton fuyuton@pastelpink.sakura.ne.jp
module Vexapion

	module Security_type
		NONE = 0
		USER_STREAM = 0x0011
		MARKET_DATA = 0x0012
		TRADE = 0x0021
		USER_DATA = 0x0022
		SYSTEM = 0x0040
	end

	# binanceのAPIラッパークラスです。
	# 各メソッドの戻り値は下記URLを参照してください。
	# @see https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md

	class Binance < BaseExchanges
		attr_writer :recv_window
		
		#@api private
		def initialize(key = nil, secret = nil)
			super(key,secret)

			@public_url = 'https://api.binance.com'
			@private_url = 'https://api.binance.com'
			@recv_window = 5000
		end

# Public API

		# @raise RequestFailed APIリクエストの失敗
		# @raise RetryException  リクエストの結果が確認できないとき 408, 500, 502, 503
		# @raise Warning APIレベルでのエラー(レスポンスのsuccess: 0の時)
		# @raise Error  クライアントエラー 400, 401, 403
		# @raise Fatal APIラッパーの修正が必要と思われるエラー, 404


		# ping
		# @return [Hash]
		def ping
			method = '/api/v1/ping'

			get(Security_type::NONE, method)
		end

		# time
		# @return [Hash]
		def time
			method = '/api/v1/time'
			
			get(method)
		end

		# exchange info
		# @return [Hash]
		def exchange_info
			method = '/api/v1/exchangeInfo'

			get(Security_type::NONE, method)
		end

		# depth
		# @param [String] symbol 取得したい通貨ペア
		# @param [Integer] limit limit default:100 max:1000 valid limits:[5, 10, 20, 50, 100, 500, 1000]
		# @return [Hash]
		def depth(symbol:, limit: 100)
			method = '/api/v1/depth'

			get(Security_type::NONE, method, symbol: symbol, limit: limit)
		end

		# trades
		# @param [String] symbol 取得したい通貨ペア
		# @param [Integer] limit limit default:500 max:500
		# @return [Array]
		def trades(symbol:, limit: nil)
			method = '/api/v1/trades'

			get(Security_type::NONE, method , symbol: symbol, limit: limit)
		end	

		# historical trades
		# @param [String] symbol 取得したい通貨ペア
		# @param [Integer] limit limit default:500 max:500
		# @param [Integer] from_id tradeId to fetch from. Default gets most recent trades.
		# @return [Array]
		def historical_trades(symbol:, limit: nil, from_id: nil)
			method = '/api/v1/historicalTrades'

			get(Security_type::MARKET_DATA, method , symbol: symbol, limit: limit, fromId: from_id)
		end	
		
		# Compressed/Aggregate trades list
		# @param [String] symbol 取得したい通貨ペア
		# @param [Integer] from_id ID to get aggregate trades from INCLUSIVE
		# @param [Integer] start_time Timestamp in ms to get aggregate trades from INCLUSIVE
		# @param [Integer] end_time Timestamp in ms to get aggregate trades from INCLUSIVE
		# @param [Integer] limit limit default:500 max:500
		# @return [Array]
		def agg_trades(symbol:, from_id: nil, start_time: nil, end_time: nil, limit: nil)
			method = '/api/v1/aggTrades'

			get(Security_type::NONE, method, symbol: symbol, fromId: from_id, startTime: start_time,
					endTime: end_time, limit: limit)
		end

		# Kline/candlestick data
		# @param [String] symbol 取得したい通貨ペア
		# @param [Integer] interval 
		# @param [Integer] limit limit default:500 max:500
		# @param [Integer] start_time Timestamp in ms to get aggregate trades from INCLUSIVE
		# @param [Integer] end_time Timestamp in ms to get aggregate trades from INCLUSIVE
		# @return [Array]
		def klines(symbol:, interval:, limit: nil, start_time: nil, end_time: nil)
			method = '/api/v1/klines'

			get(Security_type::NONE, method, symbol:symbol, interval:interval, limit:limit,
					startTime: start_time, endTime: end_time)
		end

		# 24hr ticker price change statistics
		# @param [String] symbol 取得したい通貨ペア
		# @return [Hash] or [Array]
		def twenty_four_hour(symbol:)
			method = '/api/v1/ticker/24hr'

			get(Security_type::NONE, method, symbol:symbol)
		end

		# Symbol price ticker
		# @param [Array] symbol 取得したい通貨ペア
		# @return [Hash] or [Array]
		def price(symbol:)
			method = '/api/v3/ticker/price'

			get(Security_type::NONE, method, symbol:symbol)
		end

		# Symbol order book ticker
		# @param [String] symbol 取得したい通貨ペア
		# @return [Hash] or [Array]
		def book_ticker(symbol: nil)
			method = '/api/v3/ticker/bookTicker'
			
			get(Security_type::NONE, method, symbol:symbol)
		end

# Account API 

	# order
	# @param [String] symbol
	# @param [String] side
	# @param [String] type
	# @param [Float] quantity
	# @param [Float] price
	# @param [String] time_in_force
	# @param [String] new_client_order_id A unique id for the order. Automatically generated if not sent.
	# @param [Float] stop_price Used with STOP_LOSS*, TAKE_PROFIT* orders
	# @param [Float] iceberg_qty Used with *LIMIT to create an iceberg order.
	# @param [String] new_order_resp_type ACK, RESULT, or FULL; default: RESULT
	def order(symbol:, side:, type:, quantity:, price: nil, time_in_force:nil, stop_price: nil,
			iceberg_qty: nil, new_order_resp_type: nil, new_client_order_id: nil)
		method = '/api/v3/order'

		post(Security_type::TRADE, method, symbol: symbol, side: side, quantity: quantity, type: type,
				price: price, timeInForce: time_in_force, stopPrice: stop_price, newClinetOrderId: new_client_order_id,
				icebergQty: iceberg_qty, newOrderRespType: new_order_resp_type)
	end

	# Test new order(TRADE)
	# @return [Hash]
	def order_test
		method = '/api/v3/order/test'

		post(Security_type::TRADE, method)
	end

	# Query order(USER_DATA)
	# @param [String] symbol
	# @param [Integer] order_id
	# @param [String] orig_client_order_id
	def query_order(symbol:, order_id: nil, orig_client_order_id: nil)
		method = '/api/v3/order'

		get(Security_type::USER_DATA, method, symbol: symbol, orderId: order_id, 
				origClientOrderId: orig_client_order_id)
	end

	# Cancel Order
	# @param [String] symbol
	# @param [Integer] order_id
	# @param [String] orig_client_order_id
	# @param [String] new_client_order_id
	# @return [Hash]
	def cancel(symbol:, order_id: nil, orig_client_order_id: nil,
			new_client_order_id: nil)
		method = '/api/v3/order'

		delete(Security_type::TRADE, method, symbol: symbol, orderId: order_id,
				origClientOrderId: orig_client_order_id, newClientOrderId: new_client_order_id)
	end

	# Open orders
	# @param [String] symbol
	def open_orders(symbol: nil)
		method = '/api/v3/openOrders'

		get(Security_type::USER_DATA, method, symbol: symbol)
	end
	
	# All orders
	# @param [String] symbol
	# @param [Integer] order_id
	# @param [Integer] limit default: 500; max: 500
	# @return [Hash]
	def all_orders(symbol:, order_id: nil, limit: nil)
		method = '/api/v3/allOrders'

		get(Security_type::USER_DATA, method, symbol: symbol, orderId: order_id, limit: limit)
	end

	# Account Information (balance)
	# @return [Hash]
	def account_information
		method = '/api/v3/account'

		get(Security_type::USER_DATA, method)
	end

	# Account trade list
	# @param [String] symbol
	# @param [Integer] limit
	# @param [Integer] from_id
	def my_trades(symbol:, limit: nil, from_id: nil)
		method = '/api/v3/myTrades'

		get(Security_type::USER_DATA, method, symbol: symbol, limit: limit, fromId: from_id)
	end

# User data stream endpoints

	# Start user data stream
	# @return [Hash]
	def open_stream
		method = '/api/v1/userDataStream'

		post(Security_type::USER_STREAM, method)
	end

	# Keepalive user data stream
	# @param [String] listen_key
	# @return [Hash]
	def keepalive_stream(listen_key:)
		method = '/api/v1/userDataStream'

		put(Security_type::USER_STREAM, method, listenKey: listen_key)
	end

	# Close user data stream
	# @param [String] listen_key
	# @return [Hash]
	def close_stream(listen_key:)
		method = '/api/v1/userDataStream'

		delete(Security_type::USER_STREAM, method, listenKey: listen_key)
	end


# WAPI

	# Withdraw
	# @param [String] asset
	# @param [String] address
	# @param [Integer] amount
	# @param [String] address_tag	Secondary address identifier for coins like XRP, XMR etc.
	# @param [String] name Description of the address
	# @return [Array]
	def withdraw(asset:, address:, amount:, address_tag: nil, name: nil)
		method = '/wapi/v1/withdraw.html'

		post(Security_type::TRADE, method, asset: asset, address: address, amount: amount,
				addressTag: address_tag, name: name)
	end

	# Deposit history
	# @param [String] asset
	# @param [Integer] status default:0 (0: pendding, 1: success)
	# @param [Integer] start_time
	# @param [Integer] end_time
	def deposit_history(asset: nil, status: nil, start_time: nil, end_time: nil)
		method = '/wapi/v1/depositHistory.html'

		get(Security_type::USER_DATA, method, asset: asset, status: status,
				startTime: start_time, endTime: end_time)
	end

	# withdraw history
	# @param [String] asset
	# @param [Integer] status default: 0 (0:Email Sent 1:Cancelled 2:Awaiting Approval 3:Rejected 4:Processing 5:Failure 6:Completed)
	# @param [Integer] start_time
	# @param [Integer] end_time
	def withdraw_history(asset: nil, status: nil, start_time: nil, end_time: nil)
		method = '/wapi/v1/withdrawHistory.html'

		get(Security_type::USER_DATA, method, asset: asset, status: status,
				startTime: start_time, endTime: end_time)
	end

	# Deposit Address
	# @param [String] asset
	# @return [Array]
	def deposit_address(asset:)
		method = '/wapi/v3/depositAddress.html'

		get(Security_type::USER_DATA, method, asset: asset)
	end

	# Account Status
	# @return [Hash]
	def account_status
		method = '/wapi/accountStatus.html'

		get(Security_type::USER_DATA, method)
	end

# System Status
	
	# system status
	# @return [Hash]
	def system_status
		method = '/wapi/v3/systemStatus.html'

		get(Security_type::SYSTEM, method)
	end


#  Create request header & body

		private 
		
		#@api private
		def get(security_type, method, **params)
			params.delete_if{ |k, v| v == nil }

			headers = {}
			headers['Content-Type'] = 'application/json; charset=utf-8'

			if !@key.nil? && ((security_type & 0x0030) != 0)
				headers['X-MBX-APIKEY'] = @key

				if (security_type & 0x0020) != 0
					params['recvWindow'] = @recv_window
					params['timestamp'] = get_millisecond
					params['signature'] = signature(URI.encode_www_form(params))
				end
			end

			url = "#{@public_url}#{method}"
			uri = URI.parse url
			uri.query = URI.encode_www_form(params)

			request = Net::HTTP::Get.new(uri.request_uri, initheader = headers)

			res = do_command(uri, request)
			#error_check(res)
			res
		end

		#@api private
		def post(security_type, method, params = {})
			params.delete_if{ |k, v| v == nil }

			uri = URI.parse @private_url + method
			headers = {}
			headers['Content-Type'] = 'application/json; charset=utf-8'

			if !@key.nil? && ((security_type & 0x0030) != 0)
				headers['X-MBX-APIKEY'] = @key

				if (security_type & 0x0020) != 0
					params['recvWindow'] = @recv_window
					params['timestamp'] = get_millisecond
					params['signature'] = signature(URI.encode_www_form(params))
				end
			end
			
			p 'post params', params
			request = Net::HTTP::Post.new(uri, initheader = headers)
			request.set_form_data(params)  #クエリをURLエンコード (p1=v1&p2=v2...)

			res = do_command(uri, request)
			#error_check(res)
			res
		end

		#@api private
		def put(security_type, method, params = {})
			params.delete_if{ |k, v| v == nil }

			uri = URI.parse @private_url + method
			headers = {}
			headers['Content-Type'] = 'application/json; charset=utf-8'

			if !@key.nil? && ((security_type & 0x0030) != 0)
				headers['X-MBX-APIKEY'] = @key

				if (security_type & 0x0020) != 0
					params['recvWindow'] = @recv_window
					params['timestamp'] = get_millisecond
					params['signature'] = signature(URI.encode_www_form(params))
				end
			end

			request = Net::HTTP::Put.new(uri, initheader = headers)
			request.set_form_data(params)  #クエリをURLエンコード (p1=v1&p2=v2...)

			res = do_command(uri, request)
			#error_check(res)
			res
		end

		#@api private
		def delete(security_type, method, params = {})
			params.delete_if{ |k, v| v == nil }

			uri = URI.parse @private_url + method
			headers = {}
			headers['Content-Type'] = 'application/json; charset=utf-8'

			if !@key.nil? && ((security_type & 0x0030) != 0)
				headers['X-MBX-APIKEY'] = @key

				if (security_type & 0x0020) != 0
					params['recvWindow'] = @recv_window
					params['timestamp'] = get_millisecond
					params['signature'] = signature(URI.encode_www_form(params))
				end
			end

			request = Net::HTTP::Delete.new(uri, initheader = headers)
			request.set_form_data(params)  #クエリをURLエンコード (p1=v1&p2=v2...)

			res = do_command(uri, request)
			#error_check(res)
			res
		end

		#@api private
		def signature(req)
			algo = OpenSSL::Digest.new('sha256')
			OpenSSL::HMAC.hexdigest(algo, @secret, req)
		end

		#@api private
		def get_millisecond
			DateTime.now.strftime('%Q').to_i
		end

		#@api private
		def error_check(res)
			if !res.nil? && res.is_a?(Hash) && res.has_key?('code')
				raise Warning.new(res['code'], res['msg'])
			end
		end

	end #of class
end #of Vexapion module
