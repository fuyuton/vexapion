# coding: utf-8

# 新しい取引所を追加するときに利用するテンプレート

require 'vexapion'
require_relative 'bitbankcc_errmsg.rb'

module Vexapion
	# bitbank.ccのAPIラッパークラスです。
	# 各メソッドの戻り値は下記URLを参照してください。
	# @see http://docs.bitbank.cc/

	class Bitbankcc < BaseExchanges

		#@api private
		def initialize(key = nil, secret = nil)
			super(key,secret)

			@public_url = 'https://public.bitbank.cc/'
			@private_url = 'https://api.bitbank.cc/v1/user'
			puts  error_message_json
			@error_message = error_message_json
		end

		#@api private
		def available_pair
		end

# Public API

		# @raise RequestFailed APIリクエストの失敗
		# @raise SocketError ソケットエラー
		# @raise RetryException  リクエストの結果が確認できないとき 408, 500, 503
		# @raise Warning 何かがおかしいと時(200 && response.body == nil), 509
		# @raise Error  クライアントエラー 400, 401, 403
		# @raise Fatal APIラッパーの修正が必要と思われるエラー, 404



		# ティッカー
		# @param [String] pair 取得したい通貨ペア
		# @return [Hash]
		def ticker(pair:)
			method = 'ticker'
			#params = { pair: pair }
			url = "#{@public_url}#{pair.downcase}/#{method.downcase}"

			#public_get('ticker', params)
			public_get(url)
		end

		# 板情報
		# @param [String] pair 取得したい通貨ペア
		# @return [Hash]
		def depth(pair:)
			method = 'depth'
			#params = { pair: pair }
			url = "#{@public_url}#{pair}/#{method.downcase}"

			#public_get('depth', params)
			public_get(url)
		end

		# 全約定履歴
		# @param [String] pair 取得したい通貨ペア
		# @option [String] date YYYYMMDD(省略可)
		# @return [Hash]
		def transactions(pair:, date: nil)
			method = 'transactions'
			#date = Time.local(2017, 10, 31, 0, 0, 0)
			if date.nil?
				url = "#{@public_url}#{pair.downcase}/#{method.downcase}"
			else
				url = "#{@public_url}#{pair.downcase}/#{method.downcase}/#{date.strftime("%Y%m%d")}"
			end
			#p url

			public_get(url)
		end

		# ローソク
		# @param [String] pair 取得したい通貨ペア
		# @param [String] span 
		# @return [Hash]
		def candlestick(pair:, span:, date:)
			method = 'candlestick'
			candle_types = { '1': '1min', '5': '5min', '15': '15min', '30': '30min', 
					'60': '1hour', '240': '4hour', '480': '8hour', '720': '12hour',
					'1440': '1day', '10080': '1week',
					#'24': '1day', '7': '1week',
			}

			#url = "#{@public_url}#{pair.downcase}/#{method.downcase}/#{candle_types[span.to_s]}/#{date}"
			url = "#{@public_url}#{pair.downcase}/#{method.downcase}/#{span}/#{date}"
			#p url

			#public_get('ticker', params)
			public_get(url)
		end

		# Assets(balance)
		# @return [Hash]
		def assets
			get('assets')
		end

		# Order(特定の)注文情報の取得
		# @param [String] pair 通貨ペア
		# @param [int] order_id 注文ID
		# @return [Hash]
		def get_order(pair:, order_id:)
			params = {
				pair: pair,
				order_id: order_id
			}

			get('spot/order', params)
		end

		# Order
		# @param [String] pair 通貨ペア
		# @param [String] amount 取引量
		# @param [float] price 取引価格
		# @param [String] side 買い/売り
		# @param [String] type 指値:limit/成行:market
		# @return [Hash]
		def order(pair:, amount:, price:, side:, type:)
			params = {
				pair: pair,
				amount: amount.to_s,
				price: price.to_f,
				side: side,
				type: type
			}

			post('/spot/order', params)
		end

		# Cancel
		# @param [String] pair 通貨ペア
		# @param [int] order_id 注文ID
		# @return [Hash]
		def cancel_order(pair:, order_id:)
			params = {
				pair: pair,
				order_id: order_id.to_i
			}

			post('/spot/cancel_order', params)
		end

		# Cancel_orders
		# @param [String] pair 通貨ペア
		# @param [Array] order_ids 複数の注文ID(INT)の配列
		# @return [Hash]
		def cancel_orders(pair:, order_ids:)
			params = {
				pair: pair,
				order_ids: order_ids
			}

			post('/spot/cancel_orders', params)
		end

		# orders_info(複数の注文情報を取得する)
		# @param [String] pair 通貨ペア
		# @param [Array] order_ids 複数の注文ID(INT)の配列
		# @return [Hash]
		def orders_info(pair:, order_ids:)
			params = {
				pair: pair,
				order_ids: order_ids
			}

			post('/spot/orders_info', params)
		end

		# active_orders(未約定リスト)
		# @param [String] pair 通貨ペア
		# @option [double] count 取得する注文数
		# @option [double] from_id 取得開始注文ID
		# @option [double] end_id 取得終了注文ID
		# @option [double] since 開始UNIXタイムスタンプ
		# @option [double] end 終了UNIXタイムスタンプ
		# @return [Hash]
		def active_orders(pair:, count: nil, from_id: nil, end_id: nil, since: nil, i_end: nil)
			params = { pair: pair }
			params[:count] 		= count 	if !count.nil?
			params[:from_id]	= from_id if !from_id.nil?
			params[:end_id]		= end_id 	if !end_id.nil?
			params[:since]		= since 	if !since.nil?
			params[:end]			= i_end 	if !i_end.nil?

			get('spot/active_orders', params)
		end

		# trade_history
		# @param [String] pair 通貨ペア
		# @option [double] count 取得する注文数
		# @option [double] order_id 注文ID
		# @option [double] i_since 開始UNIXタイムスタンプ
		# @option [double] i_end 終了UNIXタイムスタンプ
		# @option [String] order 約定時刻順序(asc/desc)
		# @return [Hash]
		def trade_history(pair:, count: 10, order_id: nil, i_since: nil, i_end: nil, order: nil)
			params = { pair: pair }
			params[:count] 		= count 	if !count.nil?
			params[:order_id]	= order_id if !order_id.nil?
			params[:since]		= i_since if !i_since.nil?
			params[:end]			= i_end 	if !i_end.nil?
			params[:order]		= order 	if !order.nil?

			get('spot/trade_history', params)
		end

		# withdrawal_account(出金アカウントを取得する)
		# @param [String] asset アセット名
		# @return [Hash]
		def withdrawal_account(asset:)
			params = { asset: asset }

			get('withdrawal_account', params)
		end

		# request_withdrawal(出金)
		# @param [String] asset アセット名(コイン名)
		# @param [String] uuid 出金アカウントのUUID
		# @param [String] amount 出金数量
		# @option [String] otp_token 2FAを設定している場合otp_tokenかsms_tokenのどちらかを指定
		# @option [String] sms_token 2FAを設定している場合otp_tokenかsms_tokenのどちらかを指定
		def request_withdrawal(asset:, uuid:, amount:, otp_token: nil, sms_token: nil)
			params = {
				asset: asset,
				uuid: uuid,
				amount: amount
			}
			params[:otp_token] = otp_token if otp_token != nil?
			params[:sms_token] = sms_token if sms_token != nil?

			post('/request_withdrawal', params)
		end


#  Create request header & body

		private 
		
		#@api private
		def public_get(url)
			#url = "#{@public_url}/#{pair.downcase}#{method.downcase}"
			uri = URI.parse url
			request = Net::HTTP::Get.new(uri.request_uri)

			res = do_command(uri, request)
			error_check(res)
			res
		end

		#@api private
		def get(method, params={})
			url = "#{@private_url}/#{method.downcase}"
			uri = URI.parse url
			uri.query = ((params == {}) ?  '' : URI.encode_www_form(params) )
			#p uri
			nonce = get_nonce.to_s
			query = uri.query == '' ? '' : "?#{uri.query}"
			message = "#{nonce}#{uri.path}#{query}"
			#p message
			sign = signature(message)

			headers = {
				'Content-Type'	=> 'application/json',
				'ACCESS-KEY'		=> @key,
				'ACCESS-NONCE'	=> nonce,
				'ACCESS-SIGNATURE'	=> sign
			}

			request = Net::HTTP::Get.new(uri.request_uri, initheader = headers)

			res = do_command(uri, request)
			error_check(res)
			res
		end

		#@api private
		def post(method, params = {})
			uri = URI.parse "#{@private_url}#{method}"
			#p uri
			body = params.to_json
			nonce = get_nonce.to_s
			message = "#{nonce}#{body}"
			sign = signature(message)

			headers = {
				'Content-Type'	=> 'application/json',
				'ACCESS-KEY'		=> @key,
				'ACCESS-NONCE'	=> nonce,
				'ACCESS-SIGNATURE'	=> sign,
				'ACCEPT'				=> 'application/json'
			}
			
			request = Net::HTTP::Post.new(uri.request_uri, initheader = headers)
			request.body = body

			res = do_command(uri, request)
			error_check(res)
			res
		end

		#@api private
		def signature(message)
			algo = OpenSSL::Digest.new('sha256')
			OpenSSL::HMAC.hexdigest(algo, @secret, message)
		end


		#@api private
		def delete(method)
			nonce = get_nonce.to_s
			uri = URI.parse "#{@private_url}#{method}"
			message = "#{nonce}#{uri.to_s}"
			sig = signature(message)
			header = headers(nonce, sig)
			request = Net::HTTP::Delete.new(uri.request_uri, header)

			res = do_command(uri, request)
			error_check(res) #TODO check require
			res
		end

		#api private
		def error_check(res)
			#p res
			if !res.nil? && res['success'] == 0 && res.has_key?('data')
				code = res['data']['code']
				puts code
				#puts @error_message
				#puts @error_message[code]
				#raise Warning.new(code, @error_message[code])
				raise Warning.new(code, code)
			end
		end

		def error_message_json

		end
	end #of class
end #of Vexapion module
