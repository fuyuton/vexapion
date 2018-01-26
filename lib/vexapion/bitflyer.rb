# coding: utf-8

require 'vexapion'

#@author @fuyuton fuyuton@pastelpink.sakura.ne.jp
module Vexapion
    
	# bitflyerのAPIラッパークラスです
	# 各メソッドの戻り値は下記URLを参照してください
	# @see https://lightning.bitflyer.jp/docs?lang=ja&_ga=1.264432847.170149243.1463313992

	class Bitflyer < BaseExchanges

		#@api private
		def initialize(key = nil, secret = nil)
			super(key, secret)

			@public_url = 'https://api.bitflyer.jp/v1/'
			@private_url = 'https://api.bitflyer.jp/v1/me/'

			set_min_interval(0.3)

			@available_product_code = ['BTC_JPY', 'FX_BTC_JPY', 'ETH_BTC']
		end

# Public API
		#板情報
		# @param [String] product_code product_codeを指定します。
		# @return [Hash]
		def board(product_code:)
			public_get('board', product_code: product_code.upcase)
		end
		alias get_board board

		#Ticker
		# @param [String] product_code product_codeを指定します。
		# @return [Hash]
		def ticker(product_code:)
			public_get('ticker', product_code: product_code.upcase)
		end
		alias get_ticker ticker

		#約定履歴
		# @param [String] product_code product_codeを指定します。
		# @param [Integer] count 結果の個数を指定します。
		# @param [Integer] before このパラメータに指定した値より小さいidを持つデータを取得します。
		# @param [Integer] after このパラメータに指定した値より大きいidを持つデータを取得します。
		# @return [Hash]
		def executions(product_code:, count: nil, before: nil, after: nil)
			params = {
			  product_code: product_code.upcase
			}
			params.merge!( pagenation(count, before, after) )
			public_get('executions', params)
		end
		#get_executionsは個人の約定履歴の取得に使っているので混同しないこと
		alias get_public_executions executions

		#チャット
		# @param [???] date 日付を指定するようです。形式不明。省略すると5日前からのデータを取得します。
		# @return [Hash]
		def get_chats(date:)
			public_get('getchats', from_date: date)
		end

		#取引所の状態
		# @return [Hash]
		def get_health
			public_get('gethealth')
		end

# Private API
		#APIキーの権限を取得
		# @return [Hash]
		def get_permissions
			get('getpermissions')
		end

		#資産残高を取得
		# @return [Hash]
		def get_balance
			get('getbalance')
		end

		#証拠金の状態を取得
		# @return [Hash]
		def get_collateral
			get('getcollateral')
		end

		#預入用BTC/ETHアドレス取得
		# @return [Hash]
		def get_addresses
			get('getaddresses')
		end
		
	#BTC/ETH預入履歴
		# @param [Integer] count 結果の個数を指定します。
		# @param [Integer] before このパラメータに指定した値より小さいidを持つデータを取得します。
		# @param [Integer] after このパラメータに指定した値より大きいidを持つデータを取得します。
		# @return [Hash]
		def get_coin_ins(count: nil, before: nil, after: nil)
		  params = Hash.new
			params.merge!( pagenation(count, before, after) )
			get('getcoinins', params)
		end

		#BTC/ETH外部送付
		# @param [String] currency 送付する通貨名を指定します。~BTC" または "ETH"を指定します。
		# @param [Float] amount 送付する数量を数値で指定します。
		# @param [String] address 送付先アドレスを指定します。
		# @param [Float] fee 追加の手数料を指定します。上限は0.0005です。
		# @param [String] code 二段階認証の確認コードです。コイン外部送付時の二段階認証を設定している場合のみ必要。
		# @return [Hash]
		def sendcoin(currency:, amount:, address:, fee: nil, code: nil)
			params = {
				currency_code: currency.upcase,
				amount:  amount.to_f,
				address: address,
			}
			unless fee.nil?
				fee = 0.0005 < fee.to_f ? 0.0005 : fee.to_f
				params[:additional_fee]  = fee
			end
			params[:code] = code.to_i  unless code.nil?

			post('sendcoin', params)
		end

		#BTC/ETH送付履歴
		# @param [Integer] count 結果の個数を指定します。
		# @param [Integer] before このパラメータに指定した値より小さいidを持つデータを取得します。
		# @param [Integer] after このパラメータに指定した値より大きいidを持つデータを取得します。
		# @return [Hash]
		def get_coin_outs(count: nil, before: nil, after: nil)
		  params = Hash.new
			params.merge!( pagenation(count, before, after) )

			get('getcoinouts', params)
		end

		#BTC/ETH送付状況確認
		# @param [String]	message_id	sendcoinAPIの戻り値を指定
		# @return [hash]
		def get_coin_outs_id(message_id:)
			params = { message_id: message_id }

			get('getcoinouts', params)
		end

		#銀行口座一覧取得
		# @return [Hash]
		def get_bank_accounts
			get('getbankaccounts')
		end

		#デポジット入金履歴
		# @param [Integer] count 結果の個数を指定します。
		# @param [Integer] before このパラメータに指定した値より小さいidを持つデータを取得します。
		# @param [Integer] after このパラメータに指定した値より大きいidを持つデータを取得します。
		# @return [Hash]
		def get_deposits(count: nil, before: nil, after: nil)
		  params = Hash.new
			params.merge!( pagenation(count, before, after) )

			get('getdeposits', params)
		end

		#デポジット解約(出金)
		# @param [String] currency 送付する通貨名を指定します。現在は"JPY"のみ対応しています。
		# @param [Integer] id 出金先口座のidを指定します。
		# @param [Integer] amount 解約する数量を指定します。
		# @param [String] code 二段階認証の確認コードです。出金時の二段階認証を設定している場合のみ必要。
		# @return [Hash]
		def withdraw(currency:, id:, amount:, code:'')
			params = {
				currency_code:    currency.upcase,
				bank_account_id:  id,
				amount:           amount
			}
			params[:code] = code if code != ''

			post('withdraw', params)
		end

		#デポジット解約履歴(出金)
		# @param [Integer] count 結果の個数を指定します。
		# @param [Integer] before このパラメータに指定した値より小さいidを持つデータを取得します。
		# @param [Integer] after このパラメータに指定した値より大きいidを持つデータを取得します。
		# @return [Hash]
		def get_withdrawals(count: nil, before: nil, after: nil)
		  params = Hash.new
			params.merge!( pagenation(count, before, after) )

			get('getwithdrawals', params)
		end


		#指値で新規注文を出す
		# @param [String] product_code product_codeを指定します。
		# @param [String] child_order_type child_order_typeを指定します。
		# @param [String] side 買い注文の場合は"BUY"、売り注文の場合は"SELL"を指定します。
		# @param [Float] price 価格を指定します。 ただしJPYの場合はInteger
		# @param [Float] size  注文数量を指定します。
		# @param [Integer] expire 期限切れまでの時間を分で指定します。省略した場合の値は43200(30日間)です。
		# @param [String] force 執行数量条件を"GTC"、"IOC"、"FOK"のいずれかで指定します。省略した場合は"GTC"です。
		# @return [Hash]
		def send_child_order(product_code:, child_order_type:, side:, price:, size:, minute_to_expire: nil, time_in_force: nil)
			params = {
				product_code:      product_code.upcase,
				child_order_type:  child_order_type.upcase,
				side:              side.upcase,
				price:             price,
				size:              size.to_f
			}
			params[:minute_to_expire]  = minute_to_expire		unless minute_to_expire.nil?
			params[:time_in_force]     = time_in_force			unless time_in_force.nil?

			post('sendchildorder', params)
		end
			
		#注文をキャンセルする
		# @param [String] product_code product_codeを指定します。
		# @param [Integer] child_order_id child_order_idを指定します。
		# @param [Integer] child_order_acceptance_id child_order_acceptance_idを指定します。
		# @return [Hash]
		def cancel_child_order(product_code:, child_order_id: nil, child_order_acceptance_id: nil)
		  params = {
			  product_code: product_code.upcase
		  }
			params[:child_order_id]	= child_order_id												unless order_id.nil?
			params[:child_order_acceptance_id]	= child_order_acceptance_id unless child_order_acceptance_id.nil?

			post('cancelchildorder', params)
		end

		#新規の親注文を出す(特殊注文)
		#https://lightning.bitflyer.jp/docs/specialorder を熟読して使用のこと
		#とても自由度が高いため、ユーザーがパラメータを組み立ててそれを引数にする
		# @return [Hash]
		def send_parent_order(params)
			post('sendparentorder', params)
		end

		#親注文をキャンセルする
		# @param [String] product_code product_codeを指定します。
		# @param [Integer] parent_order_id parent_order_idを指定します。(parent_order_acceptance_idとどちらかを指定)
		# @param [Integer] parent_order_acceptance_id parent_order_acceptance_idを指定します。(parent_order_idとどちらかを指定)
		# @return [Hash]
		def cancel_parent_order(product_code:, parent_order_id: nil, parent_order_acceptance_id: nil)
		  params = {
			  product_code: product_code.upcase
		  }
			params[:parent_order_id]	= parent_order_id unless parent_order_id.nil?
			params[:parent_order_acceptance_id]	= parent_order_acceptance_id unless parent_order_acceptance_id.nil?

			post('cancelparentorder', params)
		end

		#すべての注文をキャンセルする
		# @param [String] product_code product_codeを指定します。
		# @return [Hash]
		def cancel_all_child_order(product_code:)
			post('cancelallchildorders', product_code: product_code.upcase)
		end

		#注文の一覧を取得
		#stateが指定されない場合、ACTIVE, COMPLETED, CANCELED, RXPIRED, REJECTEDのすべてが返されます。
		# @param [String] product_code product_codeを指定します。
		# @param [String] child_order_state ACTIVE, COMPLETED, CANCELED, RXPIRED, REJECTEDのいずれかを指定します。省略可。
		# @param [String] parent_order_id 省略可。
		# @param [Integer] count 結果の個数を指定します。
		# @param [Integer] before このパラメータに指定した値より小さいidを持つデータを取得します。
		# @param [Integer] after このパラメータに指定した値より大きいidを持つデータを取得します。
		# @return [Hash]
		def get_child_orders(product_code:, child_order_state: nil, parent_order_id: nil, count: nil, before: nil, after: nil)
			params = {
				product_code: product_code.upcase
			}
			params.merge!( child_order_state: child_order_state ) unless child_order_state.nil?
			params.merge!( parent_order_id: parent_order_id ) unless parent_order_id.nil?

			params.merge!( pagenation(count, before, after) )

			get('getchildorders', params)
		end

		#親注文の一覧を取得
		# @param [String] product_code product_codeを指定します。
		# @param [String] parent_order_state ACTIVE, COMPLETED, CANCELED, RXPIRED, REJECTEDのいずれかを指定します。省略可。
		# @param [Integer] count 結果の個数を指定します。
		# @param [Integer] before このパラメータに指定した値より小さいidを持つデータを取得します。
		# @param [Integer] after このパラメータに指定した値より大きいidを持つデータを取得します。
		# @return [Hash]
		def get_parent_orders(product_code:, parent_order_state: nil, count: nil, before: nil, after: nil)
			params = {
				product_code: product_code.upcase
			}
			params[:parent_order_state]	= parent_order_state unless parent_order_state.nil?

			params.merge!( pagenation(count, before, after) )

			get('getparentorders', params)
		end

		#親注文の詳細を取得
		# @param [Integer] parent_order_id parent_order_idを指定します。
		# @param [Integer] parent_order_acceptance_id parent_order_acceptance_idを指定します。
		# @return [Hash]
		def get_parent_order(parent_order_id: nil, parent_order_acceptance_id:)
			params[:parent_order_id]  = parent_order_id unless parent_order_id.nil?
			params[:parent_order_acceptance_id]  = parent_order_acceptance_id unless parent_order_acceptance_id.nil?

			get('getparentorder', params)
		end

		#約定の一覧を取得
		# @param [String] product_code product_codeを指定します。
		# @param [Integer] count 結果の個数を指定します。
		# @param [Integer] before このパラメータに指定した値より小さいidを持つデータを取得します。
		# @param [Integer] after このパラメータに指定した値より大きいidを持つデータを取得します。
		# @return [Hash]
		def get_executions(product_code:, count: nil, before: nil, after: nil)
			params = {
				product_code: product_code.upcase
			}
			params.merge!( pagenation(count, before, after) )

			get('getexecutions', params)
		end

		#child_order_idに関連した約定の一覧を取得
		# @param [String] product_code product_codeを指定します。
		# @param [Integer] child_order_id child_order_idを指定します。
		# @return [Hash]
		def get_executions_child_order_id(product_code:, child_order_id: nil, child_order_acceptance_id: nil)
			#必須パラメータ
			params = {
				product_code: product_code.upcase
			}

			get('getexecutions', params)
		end

		#child_order_acceptance_idに関連した約定の一覧を取得
		# @param [String] product_code product_codeを指定します。
		# @param [Integer] child_order_id child_order_idを指定します。(省略可)
		# @param [Integer] child_order_acceptance_id child_order_acceptance_idを指定します。(省略可)
		# @return [Hash]
		def get_executions_acceptance_id(product_code:, child_order_id: nil, child_order_acceptance_id: nil)
			params = {
				product_code: product_code.upcase
			}
			params[:child_order_id]	= child_order_id unless child_order_id.nil?
			params[:child_order_acceptance_id]	= child_order_acceptance_id unless child_order_acceptance_id.nil?

			get('getexecutions', params)
		end

		# 建玉の一覧を取得
		# @param [String] product_code product_codeを指定します。 "FX_BTC_JPY"を指定します。
		# @return [Hash]
		def get_positions(product_code:)
			params = {
				product_code: product_code.upcase
			}

			get('getpositions', params)
		end


# Create request header & body

		private 
		
		#@api private
		def public_get(command, query={})
			uri = URI.parse "#{@public_url}#{command}"
			uri.query = URI.encode_www_form(query)
			request = Net::HTTP::Get.new(uri.request_uri)
			request.set_form_data(query) #クエリをURLエンコード(p1=v1&p2=v2...)

			do_command(uri, request)
		end

		#@api private
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

			request = Net::HTTP::Get.new(uri.request_uri, header)

			do_command(uri, request)
		end

		#@api private
		def post(command, params={})
			method = 'POST'
			uri = URI.parse "#{@private_url}#{command}"
			timestamp = get_nonce.to_s
			body = params.to_json #add

			text = "#{timestamp}#{method}#{uri.request_uri}#{body}"
			sign = signature(text)
			header = headers(sign, timestamp)
			request = Net::HTTP::Post.new(uri.request_uri, header)
			request.body = body

			res = do_command(uri, request)
			#error_check(res)
			res
		end

		#@api private
		def signature(data)
			algo = OpenSSL::Digest.new('sha256')
			OpenSSL::HMAC.hexdigest(algo, @secret, data)
		end

		#@api private
		def headers(sign, timestamp)
			{
				'ACCESS-KEY'        => @key,
				'ACCESS-TIMESTAMP'  => timestamp,
				'ACCESS-SIGN'       => sign,
				'Content-Type'      => 'application/json'
			}
		end

		#@api private
		def pagenation(count, before, after)
			params = Hash.new
			params.merge!( count: count ) unless count.nil?
			params.merge!( before: before ) unless before.nil?
			params.merge!( after: after ) unless after.nil?
			params
		end

		#@api private
		def error_check(res)
			if !res.nil? && res['success'] == 0 && res.has_key?('error')
				raise Warning.new(0, res['error'])
			end
		end

	end #of class
end #of module
