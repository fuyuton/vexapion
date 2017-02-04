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

		class Coincheck < BaseExchanger

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
			def ticker
				public_get('ticker')
			end

			def trades
				public_get('trades')
			end

			def order_books
				public_get('order_books')
			end
			
			#def rate(order_type, pair, price='', amount='')
			#	params = {
			#		'order_type'	=>	order_type,
			#		'pair'				=>	pair.downcase,
			#	}
			#	params['price'] = price if price != ''
			#	params['amount'] = amount if amount != ''

			#	public_get('exchange/orders/rate')
			#end
			
			#def sales_rate(order_type, pair, price='', amount='')
			#	params = {
			#		'order_type'	=>	order_type,
			#		'pair'				=>	pair.downcase,
			#	}
			#	params['price'] = price if price != ''
			#	params['amount'] = amount if amount != ''

			#	public_get('exchange/orders/rate')
			#end
			
###########################################################################
#
# Trade(Private) API
#
###########################################################################

			#長くなって訳わからなくなるので、order_typeごとに分割
			# 注文: buy/sell => order
			# 成行注文: market_buy/market_sell => market_buy/market_sell
			# レバレッジ注文・レバレッジ成行注文: leverage_buy/leverage_sell => order_leverage
			# レバレッジ注文クローズ: close_short/close_long => close_position

			# orders APIがややこしいので、一般的なものに置き換え
			# order_typeに buy / sell を指定する 
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
			#buyの時はamountにJPYの数量を指定する
			#sellの時はamountにBTCの数量を指定する
			def market_order(pair, order_type, amount, stop_loss_rate = '')
				params = {
				  'rate'				=> rate,
					'pair'				=> pair.downcase,
					'order_type'	=> "market_#{order_type.downcase}"
				}
				case order_type
				  when 'buy'
					  params['market_buy_amount']	=	amount			#JPYの数量を指定する
				  when 'sell'
					  params['amount']	=	amount			#BTCの数量を指定する
				end
				params['stop_loss_rate'] = stop_loss_rate if stop_loss_rate != ''

				post('exchange/orders', params)
			end


			#レバレッジ新規取引
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
			# close_position*() はclose_positionに、long / short を指定すること
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

			def opens
				get('exchange/orders/opens')
			end

			def cancel(id)
				delete("exchange/orders/#{id}")
			end

			def transactions
				get('exchange/orders/transactions')
			end

			def position(params = {})
				get('exchange/leverage/positions', params)
			end

			def balance
				get('accounts/balance')
			end

			def leverage_balance
				get('accounts/leverage_balance')
			end

			def send_money(address, amount)
				post('send_money', 'address' => address, 'amount' => amount)
			end

			def send_history(currency = 'BTC')
				get('send_money', 'currency' =>  currency)
			end

			def deposit_history(currency = 'BTC')
				get('deposit_money', 'currency' =>  currency)
			end

			def deposit_accelerate(id)
				post("deposit_money/#{id}/fast")
			end

			def accounts
				get('accounts')
			end


###########################################################################
#
# Private API (JPY BANK)
#
###########################################################################
			def bank_accounts
				return if withdraw == false

				get('bank_accounts')
			end

			# https://coincheck.com/ja/documents/exchange/api#withdraws-jpy
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

			def delete_bank_account(id)
				return if withdraw == false

				delete("bank_accounts/#{id}")
			end

			def bank_withdraw_history
				return if withdraw == false

				get('withdraws')
			end

		  # https://coincheck.com/ja/documents/exchange/api#withdraws-create
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

			def cancel_bank_withdraw(id)
				return if withdraw == false

				delete("withdraws/#{id}")
			end

#####################################################################
#
# 信用取引
#
#####################################################################
			def borrow(amount, currency)
				params = { 'amount' => amount, 'currency' => currency }

				post('lending/borrows', params)
			end

			def borrow_list
				get('lending/borrows/matches')
			end

			def repayment(id)
				post("lending/borrows/#{id}/repay")
			end

#####################################################################
# transfers (レバレッジアカウントへ振替)
#####################################################################
			def to_leverage(amount, currency)
				params = { 'currency' => currency, 'amount' => amount }

				post('exchange/transfers/to_leverage', params)
			end

			def from_leverage(amount, currency)
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
				url = "#{@public_url}#{method}"
				uri = URI.parse url
				request = Net::HTTP::Get.new(uri.request_uri)

				do_command(uri, request)
			end

			def get(method, params = "")
				nonce = get_nonce.to_s
				url = @private_url + method
				uri = URI.parse url
				body = params == "" ? "" : params.to_json	#URI.encode_www_form(params)

				message = "#{nonce}#{uri.to_s}"	#{body}"
				sig = signature(message)
				headers = header(nonce, sig)
				request = Net::HTTP::Get.new(uri.request_uri, headers)

				do_command(uri, request)
			end

			def post(method, params = nil)
				nonce = get_nonce.to_s
				url = @private_url + method
				uri = URI.parse url
				body = params.nil? ? nil : params	#URI.encode_www_form(params)

				message = "#{nonce}#{uri.to_s}#{body}"
				sig = signature(message)
				headers = header(nonce, sig)
				request = Net::HTTP::Post.new(uri.request_uri, initheader = headers)
				puts request.header
				request.body = body if !params.nil?

				do_command(uri, request)
			end

			def delete(method)
				nonce = get_nonce.to_s
				url = @private_url + method
				uri = URI.parse url
				message = nonce + uri.to_s
				sig = signature(message)
				headers = header(nonce, sig)
				request = Net::HTTP::Delete.new(uri.request_uri, headers)

				do_command(uri, request)
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
