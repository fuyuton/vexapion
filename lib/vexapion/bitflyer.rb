#
# bitflyer_api.rb
#
# written by @fuyuton
#
# since 2016/12/04
# ver 1.0
#

#注意事項
#Private APIの呼び出し回数制限: 1分間に約200回
#IPアドレスごとに1分間に約500回
#
#1日の平均約定単価が0.01未満の場合、翌日のPrivate API呼び出しが1分間に
#約10回まで制限されることがあります。

#https://lightning.bitflyer.jp/docs?lang=ja&_ga=1.33238398.170149243.1463313992


require 'vexapion'

module Vexapion
  module API

		class Bitflyer < BaseExchanger
			def initialize(key = nil, secret = nil)
				super(key, secret)

				@public_url = 'https://api.bitflyer.jp/v1/'
				@private_url = 'https://api.bitflyer.jp/v1/me/'

				@available_pair = ['BTC_JPY', 'FX_BTC_JPY', 'ETH_BTC']
			end

###########################################################################
#
# Public API
#
###########################################################################
			#板情報
			def board(pair)
				public_get('board', product_code: pair)
			end
			alias get_board board

			#Ticker
			def ticker(pair)
				public_get('ticker', product_code: pair)
			end
			alias get_ticker ticker

			#約定履歴
			def executions(pair, count=100, before=0, after=0)
				public_get('executions', product_code: pair,
					count: count, before: before, after: after)
			end
			#get_executionsは個人の約定履歴の取得に使っているので混同しないこと
			alias get_public_executions executions

			#チャット
			def get_chats(date)
				public_get('getchats', from_date: date)
			end

			#取引所の状態
			def get_health
				public_get('gethealth')
			end

###########################################################################
#
# Private API
#
###########################################################################
			#APIキーの権限を取得
			def get_permissions
				get('getpermissions')
			end

###########################################################################
#
# 資産
#
###########################################################################
			#資産残高を取得
			def get_balance
				get('getbalance')
			end

			#証拠金の状態を取得
			def get_collateral
				get('getcollateral')
			end

###########################################################################
#
# 入出金
#
###########################################################################
			#預入用BTC/ETHアドレス取得
			def get_addresses
				get('getaddresses')
			end
			
		#BTC/ETH預入履歴
			def get_coin_ins(count=100, before=0, after=0)
				get('getcoinins', count: count, before: before, after: after)
			end

			#BTC/ETH外部送付
			def sendcoin(currency, amount, address, fee=0.0, code='')
				params = {
					currency_code: currency,
					amount: amount.to_f,
					address: address,
				}
				fee = 0.0005 < fee.to_f ? 0.0005 : fee.to_f
				params['additional_fee']	= fee		if fee != 0.0
				params['code']						= code.to_i	if code != ''

				post('sendcoin', params)
			end

			#BTC/ETH送付履歴
			def get_coin_outs(count=100, before=0, after=0)
				params = {
					count: 	count,
					before: before,
					after: 	after
				}

				get('getcoinouts', params)
			end

			def get_coin_outs_id(id)
				params = { message_id: id }

				get('getcoinouts', params)
			end

			#銀行口座一覧取得
			def get_bank_accounts
				get('getbankaccounts')
			end

			#デポジット入金履歴
			def get_deposits(count=100, before=0, after=0)
				params = {
					count:	count,
					before:	before,
					after:	after
				}

				get('getdeposits', params)
			end

			#デポジット解約(出金)
			def withdraw(currency, id, amount, code='')
				params = {
					currency_code:		currency,
					bank_account_id:	id,
					amount:						amount
				}
				params['code'] = code if code != ''

				post('withdraw', params)
			end

			#デポジット解約履歴(出金)
			def get_withdrawals(count=100, before=0, after=0)
				params = {
					count:	count,
					before: before,
					after:	after
				}

				get('getwithdrawals', params)
			end


###########################################################################
#
# トレード
#
###########################################################################
			#新規注文を出す
			def send_child_order(pair, type, side, price, size, expire='', force='')
				params = {
					product_code:			pair,
					child_order_type:	type,
					side:							side,
					price:						price,
					size:							size
				}
				params['minute_to_expire']	= expire	if expire != ''
				params['time_in_force']			= force		if force != ''

				post('sendchildorder', params)
			end
				
			#注文をキャンセルする
			def cancel_child_order(pair, order_id='', order_acceptance_id='')
				if order_id != ''
					params = {
						product_code:		pair,
						child_order_id:	order_id
					}
				else
					params = {
						product_code:								pair,
						child_order_acceptance_id:	order_acceptance_id
					}
				end

				post('cancelchildorder', params)
			end

			#child_order_idを指定して、注文をキャンセルする
			def cancel_child_order_id(pair, order_id)
				params = {
					product_code:		pair,
					child_order_id:	order_id
				}

				post('cancelchildorder', params)
			end

			#child_order_acceptance_idを指定して、注文をキャンセルする
			def cancel_child_order_acceptance_id(pair, acceptance_id)
				params = {
					product_code:								pair,
					child_order_acceptance_id:	acceptance_id
				}

				post('cancelchildorder', params)
			end

			#新規の親注文を出す(特殊注文)
			#https://lightning.bitflyer.jp/docs/specialorder を熟読して使用のこと
			#とても自由度が高いため、ユーザーがパラメータを組み立ててそれを引数にする
			def send_parent_order(params)
				post('sendparentorder', params)
			end

			#parent_order_idを指定して、親注文をキャンセルする
			def cancel_parent_order_id(pair, order_id)
				post('cancelparentorder', product_code: pair, parent_order_id: order_id)
			end

			#parent_order_acceptance_idを指定して、親注文をキャンセルする
			def cancel_parent_order_acceptance_id(pair, acceptance_id)
				post('cancelparentorder', product_code: pair,
					parent_order_acceptance_id: acceptance_id)
			end

			#すべての注文をキャンセルする
			def cancel_all_child_order(pair)
				post('cancelallchildorder', product_code: pair)
			end

			#注文の一覧を取得
			def get_child_orders(pair, count=100, before=0, after=0, state='', pid='')
				params = {
					product_code: pair,
					count: count,
					before: before,
					after: after
				}
				params['child_order_state']	= state	if state != ''
				params['parent_order_id']		= pid		if pid != ''

				get('getchildorders', params)
			end

			#親注文の一覧を取得
			def get_parent_orders(pair, count=100, before=0, after=0, state='')
				params = {
					product_code: pair,
					count: count,
					before: before,
					after: after
				}
				params['parent_order_state']	= state	if state != ''

				get('getparentorders', params)
			end

			#parent_order_idを指定して、親注文の詳細を取得
			def get_parent_order(parent_order_id)
				get('getparentorder', parent_order_id: parent_order_id)
			end

			#parent_order_acceptance_idを指定して、親注文の詳細を取得
			def get_parent_order(acceptance_id)
				get('getparentorder', parent_order_acceptance_id: acceptance_id)
			end

			#約定の一覧を取得
			def get_executions(pair, count=100, before=0, after=0, child_order_id='',
					child_order_acceptance_id='')
				params = {
					product_code: pair,
					count: 				count,
					before: 			before,
					after: 				after
				}
				params['child_order_id'] = child_order_id if child_order_id != ''

				if child_order_acceptance_id != ''
					params['child_order_acceptance_id']	= child_order_acceptance_id	
				end

				get('getparentorders', params)
			end

			#建玉の一覧を取得
			def get_positions(pair)
				get('getpositions', product_code: pair)
			end


###########################################################################
#
#  Create request header & body
#
###########################################################################
			private 
			
			def public_get(command, query={})
				uri = URI.parse @public_url + command
				request = Net::HTTP::Get.new(uri.request_uri)
				#request.set_form_data(query) #クエリをURLエンコード(p1=v1&p2=v2...)

				do_command(uri, request)
			end

			def get(command, query={})
				method = 'GET'
				uri = URI.parse @private_url + command
				timestamp = get_nonce.to_s
				text = timestamp + method + uri.request_uri
				sign = signature(text)
				header = {
					'ACCESS-KEY'				=>	@key,
					'ACCESS-TIMESTAMP'	=>	timestamp,
					'ACCESS-SIGN'				=>	sign
				}

				request = Net::HTTP::Get.new(uri.request_uri, initheader = header)
				request.set_form_data(query) #クエリをURLエンコード(p1=v1&p2=v2...)

				do_command(uri, request)
			end

			def post(command, body={})
				method = 'POST'
				uri = URI.parse @private_url + command
				timestamp = get_nonce.to_s
				path = uri.path

				text = timestamp + method + uri.request_uri
				sign = signature(text)
				header = headers(signature(text), timestamp)
				request = Net::HTTP::Post.new(uri.request_uri, initheader = header)

				do_command(uri, request)
			end

			#def do_command(uri, request)
			#	response = nil
			#	begin
			#		response = @conn.http_request(uri,request)
			#	rescue Error => e
			#		#handle_api_error(e.response)
					#raise e
			#		raise
			#	end

			#	response.nil? ? nil : JSON.parse(response)
			#end

				

			def signature(data)
				algo = OpenSSL::Digest.new('sha256')
				OpenSSL::HMAC.hexdigest(algo, @secret, data)
			end

			def headers(sign, timestamp)
				headers = {
					'ACCESS-KEY'				=>	@key,
					'ACCESS-TIMESTAMP'	=>	timestamp,
					'ACCESS-SIGN'				=>	sign,
					'Content-Type'			=>	'application/json'
				}
			end

			#def get_nonce
			#	@nonce += 1
			#end

		end #of class
	end #of module
end #of module
