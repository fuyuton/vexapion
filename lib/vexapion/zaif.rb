# Zaif Exchange API Ver 1.05.02 対応版
# 2017/1/21現在

require 'vexapion'

module Vexapion
  module API

		# zaifのAPIラッパークラスです。
		# 各メソッドの戻り値は下記URLを参照してください。
		# @see https://corp.zaif.jp/api-docs/

		class Zaif < BaseExchanges

			def initialize(key = nil, secret = nil)
				super(key,secret)

				@public_url = 'https://api.zaif.jp/api/1/'
				@private_url = 'https://api.zaif.jp/tapi'
			end

			def available_pair
				#balanceから取れるかもしれない
				['btc_jpy', 'xem_jpy', 'xem_btc',
					'mona_jpy', 'mona_btc', 'zaif_jpy', 'zaif_btc']
			end

###########################################################################
#
# Public API
#
###########################################################################

			# @raise RequestFailed APIリクエストの失敗
			# @raise SocketError ソケットエラー
			# @raise RetryException	リクエストの結果が確認できないとき 408, 500, 503
			# @raise Warning 何かがおかしいと時(200 && response.body == nil), 509
			# @raise Error  クライアントエラー 400, 401, 403
			# @raise Fatal APIラッパーの修正が必要と思われるエラー, 404


			# 終値
			# @param [String] pair 取得したい通貨ペア
			# @return [Hash]
			def last_price(pair)
				get('last_price', pair)
			end

			# ティッカー
			# @param [String] pair 取得したい通貨ペア
			# @return [Hash]
			def ticker(pair)
				get('ticker', pair)
			end

			# 取引履歴
			# @param [String] pair 取得したい通貨ペア
			# @return [Array]
			def trades(pair)
				get('trades', pair)
			end

			# 板情報
			# @param [String] pair 取得したい通貨ペア
			# @return [Hash]
			def depth(pair)
				get('depth', pair)
			end

###########################################################################
#
# Trade(Private) API
#
###########################################################################

			# 現在の残高(余力および残高・トークン)、APIキーの権限、過去のトレード数
			# アクティブな注文数、サーバーのタイムスタンプを取得します
			# @return [Hash]
			def get_info
				post('get_info')
			end

			# 現在の残高(余力および残高・トークン)、APIキーの権限、
			# アクティブな注文数、サーバーのタイムスタンプを取得します
			# @return [Hash]
			def get_info2
				post('get_info2')
			end

			# チャットに使用されるニックネームと画像のパスを返します。
			# @return [Hash]
			def get_personal_info
				post('get_personal_info')
			end
			
			# 未約定の注文一覧を取得します
			#	@param [String]		pair		取得したい通貨ペア。省略時はすべての通貨ペア
			# @return [Hash]
			def active_orders(pair = '')
				params = Hash.new
				params['currency_pair'] = pair if pair != ''

				post('active_orders', params)
			end

			# 未約定の注文一覧を取得します
			#	@param [String]		pair		トレードしたい通貨ペア
			#	@param [String]		action	注文の種類 ask(売)/bid(買)
			#	@param [Float]		price		注文価格(ただしBTC_JPYの時はInteger)
			#	@param [Float]		amount	注文量
			#	@param [Float]		limit		リミット注文価格(ただしBTC_JPYの時はInteger)
			# @return [Hash]
			def trade(pair, action, price, amount, limit = '')
				params = {
					currency_pair:	pair,
				  action:					action,
					price:					price,
					amount:					amount
				}
				params['limit'] = limit if limit != ''

				post('trade', params)
			end

			#注文のキャンセルをします
			# @param	[Integer]	id			注文ID
			#	@return	[Hash]
			def cancel_order(id)
				post('cancel_order', order_id: id)
			end

			# トレードヒストリーを取得します。
			# @param [String]		pair 			取得したい通貨ペア
			# @param [Integer]	i_since		開始タイムスタンプ(UNIX time)
			# @param [Integer]	i_end			終了タイムスタンプ(UNIX time)
			# @param [Integer]	i_from		この順番のレコードから取得
			# @param [Integer]	i_count		取得するレコード数
			# @param [Integer]	from_id		このトランザクションIDのレコードから取得
			# @param [Integer]	end_id		このトランザクションIDのレコードまで取得
			# @param [String]		order			ソート順('ASC'/'DESC')
			# @return [Hash]
			def trade_history(pair = '', i_since = '', i_end = '',
				i_from = '', i_count = '', from_id = '', end_id = '', order = '')

				params = Hash.new
				params['currency_pair']	= pair		if pair			!= ''
				params['since']					= i_since	if i_since	!= ''
				params['end']						= i_end		if i_end		!= ''
				params['from']					= i_from	if i_from		!= ''
				params['count']					= i_count	if i_count	!= ''
				params['from_id']				= from_id	if from_id	!= ''
				params['end_id']				= end_id	if end_id		!= ''
				params['order']					= order		if order		!= ''

				post('trade_history', params)
			end

###########################################################################
#
# Trade(Private) API
#
###########################################################################

			# 払出のリクエストをします。
			#	@param [String]		currency	払出したい通貨
			#	@param [Float]		amount		送金量
			#	@param [String]		address		送信先アドレス
			#	@param [Float]		fee				採掘者への手数料(XEM以外)
			# @param [String]		message		送信メッセージ(XEMのみ)
			# @return [Hash]
			def withdraw(currency, amount, address, fee = nil, message = nil)
				params = {
				  currency:	currency.downcase,
				  amount:		amount,
				  address:	address
				}
				params['message'] = message if message	!= nil
				params['opt_fee'] = fee 		if fee 			!= nil

				post('withdraw', params)
			end

			# 入金履歴を取得します。
			#	@param [String]		currency	取得したい通貨
			# @param [Integer]	i_since		開始タイムスタンプ(UNIX time)
			# @param [Integer]	i_end			終了タイムスタンプ(UNIX time)
			# @param [Integer]	i_from		この順番のレコードから取得
			# @param [Integer]	i_count		取得するレコード数
			# @param [Integer]	from_id		このトランザクションIDのレコードから取得
			# @param [Integer]	end_id		このトランザクションIDのレコードまで取得
			# @param [String]		order			ソート順('ASC'/'DESC')
			# @return [Hash]
			def deposit_history(currency, i_since = '', i_end = '',
				i_from = '', i_count = '', from_id = '', end_id = '', order = '')

				params = Hash.new
				params['currency']	= currency
				params['since']			= i_since	if i_since 	!= ''
				params['end']				= i_end		if i_end 		!= ''
				params['from']			= i_from	if i_from 	!= ''
				params['count']			= i_count	if i_count 	!= ''
				params['from_id']		= from_id	if from_id 	!= ''
				params['end_id']		= end_id	if end_id 	!= ''
				params['order']			= order		if order 		!= ''

				post('deposit_history', params)
			end

			# 出金履歴を取得します。
			#	@param [String]		currency	取得したい通貨
			# @param [Integer]	i_since		開始タイムスタンプ(UNIX time)
			# @param [Integer]	i_end			終了タイムスタンプ(UNIX time)
			# @param [Integer]	i_from		この順番のレコードから取得
			# @param [Integer]	i_count		取得するレコード数
			# @param [Integer]	from_id		このトランザクションIDのレコードから取得
			# @param [Integer]	end_id		このトランザクションIDのレコードまで取得
			# @param [String]		order			ソート順('ASC'/'DESC')
			# @return [Hash]
			def withdraw_history(currency, i_since = '', i_end = '',
				i_from = '', i_count = '', from_id = '', end_id = '', order = '')

				params = Hash.new
				params['currency']	= currency
				params['since']			= i_since	if i_since 	!= ''
				params['end']				= i_end		if i_end 		!= ''
				params['from']			= i_from	if i_from 	!= ''
				params['count']			= i_count	if i_count	!= ''
				params['from_id']		= from_id	if from_id	!= ''
				params['end_id']		= end_id	if end_id		!= ''
				params['order']			= order		if order		!= ''

				post('withdraw_history', params)
			end

###########################################################################
#
#  Create request header & body
#
###########################################################################
		  private 
			
			def get(method, pair)
			  url = "#{@public_url}#{method.downcase}/#{pair.downcase}"
				uri = URI.parse url
				request = Net::HTTP::Get.new(uri.request_uri)

				do_command(uri, request)
			end

			def post(method, params = {})
				uri = URI.parse @private_url
				params['method'] = method
				params['nonce'] = get_nonce

				request = Net::HTTP::Post.new(uri)
				request.set_form_data(params)	#クエリをURLエンコード (p1=v1&p2=v2...)
				request['Key']	= @key
				request['Sign'] = signature(request)

				res = do_command(uri, request)
				error_check(res)
				res
			end

			def signature(req)
				algo = OpenSSL::Digest.new('sha512')
				OpenSSL::HMAC.hexdigest(algo, @secret, req.body)
			end

		end #of class
	end #of API module
end #of Vexapion module
