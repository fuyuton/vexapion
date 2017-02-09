# coding: utf-8

require 'vexapion'

module Vexapion
    
	# bitflyerのAPIラッパークラスです
	# 各メソッドの戻り値は下記URLを参照してください
	# @see https://lightning.bitflyer.jp/docs?lang=ja&_ga=1.264432847.170149243.1463313992

	class Bitflyer < BaseExchanges
		
		def initialize(key = nil, secret = nil)
			super(key, secret)

			@public_url = 'https://api.bitflyer.jp/v1/'
			@private_url = 'https://api.bitflyer.jp/v1/me/'

			set_min_interval(0.3)

			@available_pair = ['BTC_JPY', 'FX_BTC_JPY', 'ETH_BTC']
		end

# Public API
		#板情報
		def board(pair)
			public_get('board', product_code: pair.upcase)
		end
		alias get_board board

		#Ticker
		def ticker(pair)
			public_get('ticker', product_code: pair.upcase)
		end
		alias get_ticker ticker

		#約定履歴
		def executions(pair, count='', before='', after='')
			params = {
			  product_code: pair.upcase
			}
			params[:count]  = count  if count  != ''
			params[:before] = before if before != ''
			params[:after]  = after  if after  != ''
			public_get('executions', params)
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

# Private API
		#APIキーの権限を取得
		def get_permissions
			get('getpermissions')
		end

		#資産残高を取得
		def get_balance
			get('getbalance')
		end

		#証拠金の状態を取得
		def get_collateral
			get('getcollateral')
		end

		#預入用BTC/ETHアドレス取得
		def get_addresses
			get('getaddresses')
		end
		
	#BTC/ETH預入履歴
		def get_coin_ins(count='', before='', after='')
		  params = Hash.new
			params[:count]  = count  if count  != ''
			params[:before] = before if before != ''
			params[:after]  = after  if after  != ''
			get('getcoinins', params)
		end

		#BTC/ETH外部送付
		def sendcoin(currency, amount, address, fee='', code='')
			params = {
				currency_code: currency.upcase,
				amount:  amount.to_f,
				address: address,
			}
			if fee != ''
				fee = 0.0005 < fee.to_f ? 0.0005 : fee.to_f
				params[:additional_fee]  = fee
			end
			params[:code]            = code.to_i  if code != ''

			post('sendcoin', params)
		end

		#BTC/ETH送付履歴
		def get_coin_outs(count='', before='', after='')
		  params = Hash.new
			#params[:message_id] = id if id     != ''
			params[:count]  = count  if count  != ''
			params[:before] = before if before != ''
			params[:after]  = after  if after  != ''

			get('getcoinouts', params)
		end

		#BTC/ETH送付状況確認
		# @params [String] message_id sendcoinAPIの戻り値を指定
		# @return [hash]
		def get_coin_outs_id(message_id)
			params = { message_id: message_id }

			get('getcoinouts', params)
		end

		#銀行口座一覧取得
		def get_bank_accounts
			get('getbankaccounts')
		end

		#デポジット入金履歴
		def get_deposits(count='', before='', after='')
		  params = Hash.new
			params[:count]  = count  if count  != ''
			params[:before] = before if before != ''
			params[:after]  = after  if after  != ''

			get('getdeposits', params)
		end

		#デポジット解約(出金)
		def withdraw(currency, id, amount, code='')
			params = {
				currency_code:    currency.upcase,
				bank_account_id:  id,
				amount:           amount
			}
			params[:code] = code if code != ''

			post('withdraw', params)
		end

		#デポジット解約履歴(出金)
		def get_withdrawals(count='', before='', after='')
		  params = Hash.new
			params[:count]  = count  if count  != ''
			params[:before] = before if before != ''
			params[:after]  = after  if after  != ''

			get('getwithdrawals', params)
		end


		#新規注文を出す
		def send_child_order(pair, type, side, price, size, expire='', force='')
			params = {
				product_code:      pair.upcase,
				child_order_type:  type.upcase,
				side:              side.upcase,
				price:             price,
				size:              size.to_f
			}
			params[:minute_to_expire]  = expire  if expire != ''
			params[:time_in_force]     = force   if force  != ''

			post('sendchildorder', params)
		end
			
		#child_order_idを指定して、注文をキャンセルする
		def cancel_child_order(pair, order_id)
			params = {
				product_code:   pair.upcase,
				child_order_id: order_id
			}

			post('cancelchildorder', params)
		end

		#child_order_acceptance_idを指定して、注文をキャンセルする
		def cancel_child_order_specify_acceptance_id(pair, acceptance_id)
			params = {
				product_code:              pair.upcase,
				child_order_acceptance_id: acceptance_id
			}

			post('cancelchildorder', params)
		end

		#新規の親注文を出す(特殊注文)
		#https://lightning.bitflyer.jp/docs/specialorder を熟読して使用のこと
		#とても自由度が高いため、ユーザーがパラメータを組み立ててそれを引数にする
		#def send_parent_order(params)
		#	post('sendparentorder', params)
		#end

		#parent_order_idを指定して、親注文をキャンセルする
		#def cancel_parent_order(pair, order_id)
		#  params = {
		#	  product_code: pair.upcase,
		#	  parent_order_id: order_id
		#  }

		#	post('cancelparentorder', params)
		#end

		#parent_order_acceptance_idを指定して、親注文をキャンセルする
		#def cancel_parent_order_specify_acceptance_id(pair, acceptance_id)
		#  params = {
		#	  product_code: pair.upcase,
		#		parent_order_acceptance_id: acceptance_id
		#	}
		#	post('cancelparentorder', params)
		#end

		#すべての注文をキャンセルする
		def cancel_all_child_order(pair)
			post('cancelallchildorders', product_code: pair.upcase)
		end

		#注文の一覧を取得
		def get_child_orders(pair, state='', pid='', count='', before='', after='')
			params = {
				product_code: pair.upcase
			}
			params[:child_order_state]  = state  if state != ''
			params[:parent_order_id]    = pid    if pid != ''
			params[:count]  = count  if count  != ''
			params[:before] = before if before != ''
			params[:after]  = after  if after  != ''

			get('getchildorders', params)
		end

		#親注文の一覧を取得
		#def get_parent_orders(pair, state='', count='', before='', after='')
		#	params = {
		#		product_code: pair.upcase
		#	}
		#	params[:parent_order_state]  = state  if state != ''
		#	params[:count]  = count  if count  != ''
		#	params[:before] = before if before != ''
		#	params[:after]  = after  if after  != ''

		#	get('getparentorders', params)
		#end

		#parent_order_idを指定して、親注文の詳細を取得
		#def get_parent_order(parent_order_id)
		#	get('getparentorder', parent_order_id: parent_order_id)
		#end

		#parent_order_acceptance_idを指定して、親注文の詳細を取得
		#def get_parent_order_specify_acceptance_id(acceptance_id)
		#	get('getparentorder', parent_order_acceptance_id: acceptance_id)
		#end

		#約定の一覧を取得
		def get_executions(pair, coid='', child_order_acceptance_id='',
			  count='', before='', after='')
			params = {
				product_code: pair.upcase
			}
			params['child_order_id'] = coid if coid != ''
			if child_order_acceptance_id != ''
				params['child_order_acceptance_id']  = child_order_acceptance_id  
			end
			params[:count]  = count  if count  != ''
			params[:before] = before if before != ''
			params[:after]  = after  if after  != ''

			get('getexecutions', params)
		end

		#建玉の一覧を取得
		def get_positions(pair='FX_BTC_JPY')
			get('getpositions', product_code: pair.upcase)
		end


# Create request header & body

		private 
		
		def public_get(command, query={})
			uri = URI.parse "#{@public_url}#{command}"
			uri.query = URI.encode_www_form(query)
			request = Net::HTTP::Get.new(uri.request_uri)
			request.set_form_data(query) #クエリをURLエンコード(p1=v1&p2=v2...)

			do_command(uri, request)
		end

		def get(command, query={})
			method = 'GET'
			uri = URI.parse "#{@private_url}#{command}"
			uri.query = URI.encode_www_form(query) if query != {}
			timestamp = get_nonce.to_s
			text = "#{timestamp}#{method}#{uri.request_uri}"
			sign = signature(text)
			header = {
				'ACCESS-KEY'        =>  @key,
				'ACCESS-TIMESTAMP'  =>  timestamp,
				'ACCESS-SIGN'        =>  sign
			}

			request = Net::HTTP::Get.new(uri.request_uri, initheader = header)

			do_command(uri, request)
		end

		def post(command, params={})
			method = 'POST'
			uri = URI.parse "#{@private_url}#{command}"
			timestamp = get_nonce.to_s
			body = params.to_json #add

			text = "#{timestamp}#{method}#{uri.request_uri}#{body}"
			sign = signature(text)
			header = headers(sign, timestamp)
			request = Net::HTTP::Post.new(uri.request_uri, initheader = header)
			request.body = body

			res = do_command(uri, request)
			error_check(res)
			res
		end

		def signature(data)
			algo = OpenSSL::Digest.new('sha256')
			OpenSSL::HMAC.hexdigest(algo, @secret, data)
		end

		def headers(sign, timestamp)
			headers = {
				'ACCESS-KEY'        => @key,
				'ACCESS-TIMESTAMP'  => timestamp,
				'ACCESS-SIGN'       => sign,
				'Content-Type'      => 'application/json'
			}
		end

	end #of class
end #of module
