# coding: utf-8

require 'vexapion'

#@author @fuyuton fuyuton@pastelpink.sakura.ne.jp
module Vexapion

	class Poloniex < BaseExchanges

		#@api private
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

		#24時間出来高
		# @return [Hash]
		def volume_24hours
			get('return24hVolume')
		end

		#Ticker
		# @return [Hash]
		def ticker
			get('returnTicker')
		end

		#板情報
		# @param [String] pair pairの指定
		# @param [Integer] depth 深さの指定
		# @return [Hash]
		def orderbook(pair:, depth:)
			get('returnOrderBook', currencyPair: pair.upcase, depth: depth)
		end

		#市場取引履歴
		# @param [String] pair pairの指定
		# @param [Integer] start_time 取得したい最初の時間(UNIX TIMEで指定)
		# @param [Integer] end_time 取得したい最後の時間(UNIX TIMEで指定)
		def market_trade_history(pair:, start_time: nil, end_time: nil)
			params = { currencyPair: pair.upcase }
			params[:start] = start_time unless start_time.nil?
			params[:end] = end_time unless end_time.nil?

			get('returnTradeHistory', params)
		end


# Trade(Private) API
		
		#手数料情報
		# @return [Hash]
		def fee_info
			post('returnFeeInfo')
		end

		#資産残高
		# @return [Hash]
		def balances
			post('returnBalances')
		end

		#資産残高
		# @return [Hash]
		def complete_balances(account:'all')
			post('returnCompleteBalances', 'account' => account)
		end

		#注文中リスト
		# @param [String] pair pairの指定
		# @return [Hash]
		def open_orders(pair:)
			post('returnOpenOrders', currencyPair: pair.upcase)
		end

		#約定リスト
		# @param [String] pair pairの指定
		# @param [Integer] start 開始時間の指定
		# @param [Integer] end_time 終了時間の指定
		# @return [Hash]
		def trade_history(pair:, start:, end_time:)
			post('returnTradeHistory', 'currencyPair' => pair.upcase,
				'start' => start, 'end' => end_time)
		end

		#買い注文
		# @param [String] pair pair
		# @param [Float] rate 買い値
		# @param [Float] amount 買いたい量
		def buy(pair:, rate:, amount:)
			post('buy', 'currencyPair' => pair.upcase, 
				'rate' => rate, 'amount' => amount)
		end
		
		#売り注文
		# @param [String] pair pair
		# @param [Float] rate 売り値
		# @param [Float] amount 売りたい量
		def sell(pair:, rate:, amount:)
			post('sell', 'currencyPair' => pair.upcase,
				'rate' => rate, 'amount' => amount)
		end
		
		#注文のキャンセル
		# @param [Integer] order_number キャンセルしたい注文番号
		# @return [Hash]
		def cancel_order(order_number:)
			post('cancelOrder', orderNumber: order_number)
		end

		#注文の移動
		# @param [Integer] order_number 移動したい注文番号
		# @param [Float] rate 移動後のレート
		def move_order(order_number:, rate:)
			post('moveOrder', 'orderNumber' => order_number, 'rate' => rate)
		end
		
		#払出
		# @param [String] currency 払い出したい通貨
		# @param [Float] amount 払い出したい量
		# @param [String] address 払出先のアドレス
		# @return [Hash]
		def withdraw(currency:, amount:, address:)
			post('widthdraw', 'currency' => currency.upcase,
				'amount' => amount, 'address' => address)
		end

		#アカウントバランス
		# @return [Hash]
		def available_account_balances
			post('returnAvailableAccountBalances')
		end

		#トレーダブルバランス
		# @return [Hash]
		def tradable_balances
			post('returnTradableBalances')
		end

		#口座間転送
		# @param [String] currency 移動したい通貨名
		# @param [Float] amount 移動したい量
		# @param [String] from_account 送り元口座
		# @param [String] to_account 送り先口座
		# @return [Hash]
		def transfer_balance(currency:, amount:, from_account:, to_account:)
			post('transferBalance', currency: currency.upcase, amount: amount,
				fromAccount: from_account, toAccount: to_account)
		end

		#マージンアカウントサマリー
		# @return [Hash]
		def margin_account_summary
			post('returnMarginAccountSummary')
		end

		#マージン取引(買い)
		# @param [String] pair pair
		# @param [Float] rate 買い値
		# @param [Float] amount 買いたい量
		def margin_buy(pair:, rate:, amount:)
			post('marginBuy', 'currencyPair' => pair.upcase,
			  'rate' => rate, 'amount' => amount)
		end

		#マージン取引(売り)
		# @param [String] pair pair
		# @param [Float] rate 売り値
		# @param [Float] amount 売りたい量
		def margin_sell(pair:, rate:, amount:)
			post('marginSell', 'currencyPair' => pair.upcase,
				'rate' => rate, 'amount' => amount)
		end

		def deposit_addresses
			post('returnDepositAddresses')
		end

		def generate_new_address(currency:)
			post('generateNewAddress', 'currency' => currency.upcase)
		end

		def deposits_withdrawals(start_time:, end_time:, count:1)
			post('returnDepositsWithdrawals',
				'start' => start_time, 'end' => end_time, 'count' => count)
		end

#  Create request header & body

		private 

		#@api private
		def get(command, params = {})
			params['command'] = command
			param = URI.encode_www_form(params)
			uri = URI.parse @public_url + param
			request = Net::HTTP::Get.new(uri.request_uri)

			res = do_command(uri, request)
			error_check(res)
			res
		end

		#@api private
		def post(command, params = {})
			params['command'] = command
			params['nonce'] = get_nonce

			post_data = URI.encode_www_form(params)
			header = headers(signature(post_data))

			uri = URI.parse @private_url 
			request = Net::HTTP::Post.new(uri.request_uri, header)
			request.body = post_data

			res = do_command(uri, request)
			error_check(res)
			res
		end

		#@api private
		def signature(data)
			algo = OpenSSL::Digest.new('sha512')
			OpenSSL::HMAC.hexdigest(algo, @secret, data)
		end

		#@api private
		def headers(sign)
			{
				'Sign'  =>  sign,
				'Key'    =>  @key
			}
		end

		#@api private
		def error_check(res)
			if !res.nil? && res['success'] == 0 && res.has_key?('errors')
				raise Warning(0, res['errors'])
			end
		end

	end #of class
end #of Vexapion module
