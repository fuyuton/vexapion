# coding: utf-8

require 'vexapion'

module Vexapion

	class Poloniex < BaseExchanges
		def initialize(key = nil, secret = nil)
			super(key, secret)
			
			@public_url = 'https://poloniex.com/public?'
			@private_url = 'https://poloniex.com/tradingApi'
			set_min_interval(0.5)
		end

		def set_min_interval(sec)
			@conn.min_interval = sec
		end


# Public API

		def volume_24hours
			get('return24Volume')
		end

		def ticker
			get('returnTicker')
		end

		def orderbook(pair, depth)
			get('returnOrderBook', currencyPair: pair, depth: depth)
		end

		def market_trade_history(pair)
			get('returnTradeHistory', currencyPair: pair)
		end


# Trade(Private) API

		def fee_info
			post('returnFeeInfo')
		end

		def balances
			post('returnBalances')
		end

		def complete_balances(account='all')
			post('returnCompleteBalances', account: account)
		end

		def open_orders(pair)
			post('returnOpenOrders', currencyPair: pair)
		end

		def trade_history(pair, start, end_time)
			post('returnTradeHistory', currencyPair: pair,
				start: start, end: end_time)
		end

		def buy(pair, rate, amount)
			post('buy', currencyPair: pair, rate: rate, amount: amount)
		end

		def sell(pair, rate, amount)
			post('sell', currencyPair: pair, rate: rate, amount: amount)
		end

		def cancel_order(order_number)
			post('cancelOrder', orderNumber: order_number)
		end

		def move_order(order_number, rate)
			post('moveOrder', orderNumber: order_number, rate: rate)
		end

		def withdraw(currency, amount, address)
			post('widthdraw', currency: currency, amount: amount, address: address)
		end

		def available_account_balances
			post('returnAvailableAccountBalances')
		end

		def tradable_balances
			post('returnTradableBalances')
		end

		def transfer_balance(currency, amount, from_ccount, to_account)
			post('transferBalance', currency: currency, amount: amount,
				fromAccount: from_ccount, toAccount: to_account)
		end

		def margin_account_summary
			post('returnMarginAccountSummary')
		end

		def margin_buy(pair, rate, amount)
			post('marginBuy', currencyPair: pair, rate: rate, amount: amount)
		end

		def margin_sell(currency_pair, rate, amount)
			post('marginSell', currencyPair: currency_pair,
				rate: rate, amount: amount)
		end

		def deposit_addresses
			post('returnDepositAddresses')
		end

		def generate_new_address(currency)
			post('generateNewAddress', currency: currency)
		end

		def deposits_withdrawals(start_time, end_time, count)
			post('returnDepositsWithdrawals',
				start: start_time, end: end_time, count: count)
		end

#  Create request header & body

		private 

		def get(command, params = {})
			params['command'] = command
			param = URI.encode_www_form(params)
			uri = URI.parse @public_url + param
			request = Net::HTTP::Get.new(uri.request_uri)

			do_command(uri, request)
		end

		def post(command, params = {})
			params['command'] = command
			params['nonce'] = get_nonce

			post_data = URI.encode_www_form(params)
			header = headers(signature(post_data))

			uri = URI.parse @private_url 
			request = Net::HTTP::Post.new(uri.request_uri, initheader = header)
			request.body = post_data

			do_command(uri, request)
		end

		def signature(data)
			algo = OpenSSL::Digest.new('sha512')
			OpenSSL::HMAC.hexdigest(algo, @secret, data)
		end

		def headers(sign)
			{
				'Sign'  =>  sign,
				'Key'    =>  @key
			}
		end

	end #of class
end #of Vexapion module
