#
# coincheck_api.rb
#
# written by @fuyuton
#
# since 2016/11/16
# ver 1.0
#
# pair = 'btc_jpy'

require 'vexapion'

module Vexapion
  module API
		
		# coincheckのAPIラッパークラスです。
		# 各メソッドの戻り値は下記URLを参照してください。
		# @see https://coincheck.com/ja/documents/exchange/api

		class Coincheck < BaseExchanges

			def initialize(key = nil, secret = nil)
				super(key, secret)

				@public_url = "https://coincheck.com/api/"
				@private_url = "https://coincheck.com/api/"
				set_verify_mode(OpenSSL::SSL::VERIFY_NONE)
				#set_verify_mode(OpenSSL::SSL::VERIFY_PEER)
			end

###########################################################################
#
# Public API
#
###########################################################################

			# @raise RequestFailed APIリクエストの失敗
			# @raise SocketError ソケットエラー
			# @raise RetryException リクエストの結果が確認できないとき 408, 500, 503
			# @raise Warning 何かがおかしい時(200 && response.body==nil), 509
			# @raise Error クライアントエラー 400, 401, 403
			# @raise Fatal APIラッパーの修正が必要と思われるエラー, 404

			# ティッカー
			# @return [Hash]
			def ticker
				public_get('ticker')
			end

			# 取引履歴
			# @return [Array]
			def trades
				public_get('trades')
			end

			# 板情報
			# @return [Hash]
			def order_books
				public_get('order_books')
			end
			
			# レート取得
			# @param [String] pair	必須 現在は'btc_jpy'のみ
			# @param [String] order_type	必須 'sell' or 'buy'
			# @param [Integer]	price	省略可 注文での金額 例28000
			# @param [Float]	amount	省略可 注文での量 例0.1
			# @return [Hash]
			def rate(pair, order_type, price='', amount='')
				params = {
					'pair'				=>	pair.downcase,
					'order_type'	=>	order_type,
				}
				params['price'] = price if price != ''
				params['amount'] = amount if amount != ''

				public_get('exchange/orders/rate')
			end
		
			# 販売所レート取得
			# @param [String] pair	('btc_jpy', 'eth_jpy', 'zec_btc' ...etc)
			# @return [Hash]
			def sales_rate(pair, price='', amount='')
				params = {
					'pair'				=>	pair.downcase,
				}

				public_get('exchange/orders/rate')
			end
			
###########################################################################
#
# Trade(Private) API
#
###########################################################################

			#長くなって訳わからなくなるので、order_typeごとに分割
			# 注文: buy/sell => order
			# 成行注文: market_buy/market_sell => market_order
			# レバレッジ注文: leverage_buy/leverage_sell => order_leverage
			# レバレッジ成行注文: leverage_buy/leverage_sell => market_order_leverage
			# レバレッジ注文クローズ: close_short/close_long => close_position
			# レバレッジ注文成行クローズ: close_short/close_long =>
			#		close_position_market_order

			# orders APIがややこしいので、一般的なものに置き換え
			# order_typeに buy / sell を指定する 


			# @param [String] pair	現在は'btc_jpy'のみ
			# @param [String] order_type 'sell' or 'buy'
			# @param [Integer]	rate	注文での金額 例28000
			# @param [Float]	amount	注文での量 例0.1
			# @param [Integer] stop_loss_rate 省略可 逆指値レート
			# @return [Hash]
			def order(pair, order_type, rate, amount, stop_loss_rate = '')
				params = {
				  'rate'				=>	rate,
				  'amount'			=>	amount,
					'pair'				=>	pair.downcase,
					'order_type' 	=>	order_type.downcase
				}
				params['stop_loss_rate'] = stop_loss_rate if stop_loss_rate != ''

				post('exchange/orders', params)
			end

			#成行注文
			#buyの時はamountにJPYの数量を指定する(amount_jpy円分買うという指定方法)
			# @param [String] pair	現在は'btc_jpy'のみ
			# @param [Float]	amount_jpy	注文での量 例5000
			# @param [Integer] stop_loss_rate 省略可 逆指値レート
			# @return [Hash]
			def market_buy(pair, amount_jpy, stop_loss_rate = '')
				params = {
					'pair'				=> pair.downcase,
					'order_type'	=> "market_buy",
					'market_buy_amount'	=>	amount_jpy
				}
				params['stop_loss_rate'] = stop_loss_rate if stop_loss_rate != ''
			
				post('exchange/orders', params)
			end

			#成行注文
			#sellの時はamountにBTCの数量を指定する
			# @param [String] pair	現在は'btc_jpy'のみ
			# @param [Float]	amount	注文での量 例0.1
			# @param [Integer] stop_loss_rate 省略可 逆指値レート
			# @return [Hash]
			def market_sell(pair, amount, stop_loss_rate = '')
				params = {
					'pair'				=> pair.downcase,
					'order_type'	=> "market_sell",
					'amount'			=>	amount
				}
				params['stop_loss_rate'] = stop_loss_rate if stop_loss_rate != ''

				post('exchange/orders', params)
			end


			#レバレッジ新規取引
			# @param [String] pair	現在は'btc_jpy'のみ
			# @param [String] order_type	'sell' or 'buy'
			# @param [Integer]	rate	注文のレート 例28000
			# @param [Float]	amount	注文での量 例0.1
			# @param [Integer] stop_loss_rate 省略可 逆指値レート
			# @return [Hash]
			def order_leverage(pair, order_type, rate, amount, stop_loss_rate = '')
				params = {
					'pair'				=> pair.downcase,
					'rate'				=> rate.to_f,
					'amount'			=> amount.to_f,
					'order_type'	=> "leverage_#{order_type.downcase}"
				}
				params['stop_loss_rate'] = stop_loss_rate if stop_loss_rate != ''

				post('exchange/orders', params)
			end
			
			#レバレッジ新規取引(成行)
			# @param [String] pair	現在は'btc_jpy'のみ
			# @param [String] order_type	'sell' or 'buy'
			# @param [Float]	amount	注文での量 例0.1
			# @param [Integer] stop_loss_rate 省略可 逆指値レート
			# @return [Hash]
			def market_order_leverage(pair, order_type, amount, stop_loss_rate = '')
				params = {
					'pair'				=> pair.downcase,
					'amount'			=> amount.to_f,
					'order_type'	=> "leverage_#{order_type.downcase}"
				}
				params['stop_loss_rate'] = stop_loss_rate if stop_loss_rate != ''

				post('exchange/orders', params)
			end

			#レバレッジ決済売買
			# @param [String] close_position	'long' or 'short'
			# @param [Integer]	position_id	ポジションID
			# @param [Integer]	rate	注文のレート 例28000
			# @param [Float]	amount	注文での量 例0.1
			# @return [Hash]
			def close_position(close_position, position_id, rate, amount)
				params = {
					'pair' 				=> pair.downcase,
					'rate'				=> rate.to_f,
					'amount'			=> amount.to_f,
					'order_type' 	=> "close_#{close_position.downcase}",
					'position_id'	=> position_id.to_i
				}

				post('exchange/orders', params) 
			end
		
			#レバレッジ決済取引(成行)
			# @param [String] close_position	'long' or 'short'
			# @param [Integer]	position_id	ポジションID
			# @param [Float]	amount	注文での量 例0.1
			# @return [Hash]
			def close_position_market_order(close_position, position_id, amount)
				params = {
					'pair' 				=> pair.downcase,
					'amount'			=> amount.to_f,
					'order_type' 	=> "close_#{close_position.downcase}",
					'position_id'	=> position_id.to_i
				}

				post('exchange/orders', params)
			end

			alias close_position_without_limit close_position_market_order

			# 未約定の注文一覧
			# @return [Hash]
			def opens
				get('exchange/orders/opens')
			end

			# 注文のキャンセル
			# @param [Integer]	id	キャンセルしたい注文ID
			# @return [Hash]
			def cancel(id)
				delete("exchange/orders/#{id}")
			end

			# 約定履歴
			# @return [Hash]
			def transactions
				get('exchange/orders/transactions')
			end

			# 約定履歴(ページネーション)
			# @return [Hash]
			def transactions
				get('exchange/orders/transactions_pagination')
			end

			# ポジション一覧
			# @param [String]	status	省略可 'open'/'closed'を指定出来ます
			# @return [Hash]
			def position(status='')
				params['status'] = status	if status != ''	
				get('exchange/leverage/positions', params)
			end
			
			# 残高
			# @return [Hash]
			def balance
				get('accounts/balance')
			end

			# レバレッジアカウントの残高
			# @return [Hash]
			def leverage_balance
				get('accounts/leverage_balance')
			end

			# ビットコインの送金
			# @param [String]	address	送り先のビットコインアドレス
			# @param [Float]	amount	送りたいビットコインの量
			# @return [Hash]
			def send_money(address, amount)
				post('send_money', 'address' => address, 'amount' => amount)
			end

			# ビットコイン送金履歴
			# @param [String] currency	現在はBTCのみ対応。省略時のデフォルトはBTC
			# @return [Hash]
			def send_history(currency = 'BTC')
				get('send_money', 'currency' =>  currency)
			end

			# ビットコイン受取履歴
			# @param [String] currency	現在はBTCのみ対応。省略時のデフォルトはBTC
			# @return [Hash]
			def deposit_history(currency = 'BTC')
				get('deposit_money', 'currency' =>  currency)
			end

			# ビットコインの高速入金
			# @param [Integer]	id	高速入金させたいビットコイン受取履歴のID
			# @return [Hash]
			def deposit_accelerate(id)
				post("deposit_money/#{id}/fast")
			end

			# アカウント情報
			# @return [Hash]
			def accounts
				get('accounts')
			end


###########################################################################
#
# Private API (JPY BANK)
#
###########################################################################
			
			# 銀行口座一覧
			# @return [Hash]
			def bank_accounts
				return if withdraw == false

				get('bank_accounts')
			end

			# 銀行口座の登録
			# @param [String] bank	銀行名
			# @param [String] branch 支店名
			# @param [String] type 口座の種類 (普通口座 futsu / 当座預金口座 toza)
			# @param [String] number_str 口座番号 例:'0123456'
			# @param [String] name 口座名義
			# @return [Hash]
			def regist_bank_account(bank, branch, type, number_str, name)
				return if withdraw == false

				params = {
					'bank_name'					=> bank,
					'branch_name'				=> branch,
					'bank_account_type'	=> type,
					'number'						=> number_str,
					'name'							=> name
				}

				post('bank_accounts', params)
			end

			# 銀行口座の削除
			# @param [Integer]	id	銀行口座一覧のID
			# @return [Hash]
			def delete_bank_account(id)
				return if withdraw == false

				delete("bank_accounts/#{id}")
			end

			# 日本円出金履歴
			# @return [Hash]
			def bank_withdraw_history
				return if withdraw == false

				get('withdraws')
			end

			# 日本円出金申請
			# @param [Integer] id 銀行口座一覧のID
			# @param [Integer] amount 金額
			# @param [String] currency 通貨名 現在はJPYのみ。省略時デフォルト'JPY'
			# @param [Boolean]	is_fast	高速出金オプション 省略時デフォルトはfalse
			# @return [Hash]
			def bank_withdraw(id, amount, currency = 'JPY', is_fast = false)
				return if withdraw == false

				params = {
					'bank_account_id'	=> id,
					'amount'		=> amount,
					'currency'	=> currency,
					'is_fast'		=> is_fast
				}

				post('withdraws', params)
			end

			# 日本円出金申請のキャンセル
			# @param [Integer]	id	出金申請のID
			# @return [Hash]
			def cancel_bank_withdraw(id)
				return if withdraw == false

				delete("withdraws/#{id}")
			end

#####################################################################
#
# 信用取引
#
#####################################################################
			
			# 借入申請
			# @param [String]	currency	借りたい通貨
			# @param [Float] amount	借りたい量
			# @return [Hash]
			def borrow(currency, amount)
				params = { 'amount' => amount, 'currency' => currency }

				post('lending/borrows', params)
			end
			
			# 借入中一覧
			# @return [Hash]
			def borrow_list
				get('lending/borrows/matches')
			end

			# 返済
			# @param [Integer]	id	借入中一覧のID
			# @return [Hash]
			def repayment(id)
				post("lending/borrows/#{id}/repay")
			end

#####################################################################
# transfers (レバレッジアカウントへ振替)
#####################################################################
			
			# レバレッジアカウントへ振替
			# @param [String]	currency	通貨 現在はJPYのみ
			# @param [Float] amount	移動する数量
			# @return [Hash]
			def to_leverage(currency, amount)
				params = { 'currency' => currency, 'amount' => amount }

				post('exchange/transfers/to_leverage', params)
			end

			# レバレッジアカウントから振替
			# @param [String]	currency	通貨 現在はJPYのみ
			# @param [Float] amount	移動する数量
			# @return [Hash]
			def from_leverage(currency, amount)
				params = { 'currency' => currency, 'amount' => amount }

				post('exchange/transfers/from_leverage', params)
			end

###########################################################################
#
#  Create request header & body
#
###########################################################################
			private 

			def public_get(method)
				uri = URI.parse "#{@public_url}#{method}"
				request = Net::HTTP::Get.new(uri.request_uri)

				do_command(uri, request)
			end

			def get(method, params = '')
				nonce = get_nonce.to_s
				uri = URI.parse "#{@private_url}#{method}"
				params = params.to_json	if params != '' #URI.encode_www_form(params)

				message = "#{nonce}#{uri.to_s}#{params}"
				sig = signature(message)
				headers = header(nonce, sig)
				request = Net::HTTP::Get.new(uri.request_uri, headers)

				res = do_command(uri, request)
				error_check(res) #TODO check require
				res
			end

			def post(method, params = '')
				nonce = get_nonce.to_s
				uri = URI.parse "#{@private_url}#{method}"
				params = params.to_json	#URI.encode_www_form(params)

				message = "#{nonce}#{uri.to_s}#{params}"
				sig = signature(message)
				headers = header(nonce, sig)
				request = Net::HTTP::Post.new(uri.request_uri, initheader = headers)
				request.body = params if params != ''

				res = do_command(uri, request)
				error_check(res) #check ok
				res
			end

			def delete(method)
				nonce = get_nonce.to_s
				uri = URI.parse "#{@private_url}#{method}"
				message = nonce + uri.to_s
				sig = signature(message)
				headers = header(nonce, sig)
				request = Net::HTTP::Delete.new(uri.request_uri, headers)

				res = do_command(uri, request)
				error_check(res) #TODO check require
				res
			end

			def signature(message)
				algo = OpenSSL::Digest.new('sha256')
				OpenSSL::HMAC.hexdigest(algo, @secret, message)
			end

			def header(nonce, signature)
				{
					'Content-Type'			=>	"application/json",
					'ACCESS-KEY' 				=>	@key,
					'ACCESS-NONCE'			=>	nonce,
					'ACCESS-SIGNATURE'	=>	signature
				}
			end

		end #of class
  end #of API module
end #of VirturalCurrencyExchanger module
