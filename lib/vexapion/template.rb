# :stopdoc:
# coding: utf-8

# 新しい取引所を追加するときに利用するテンプレート

require 'vexapion'

module Vexapion

	# ....のAPIラッパークラスです。
	# 各メソッドの戻り値は下記URLを参照してください。
	# @see http://....

	class NewExchangesName < BaseExchanges

		def initialize(key = nil, secret = nil)
			super(key,secret)

			@public_url = 'https://...'
			@private_url = 'https://...'
		end

		def available_pair
		end

# Public API

		# @raise RequestFailed APIリクエストの失敗
		# @raise SocketError ソケットエラー
		# @raise RetryException  リクエストの結果が確認できないとき 408, 500, 503
		# @raise Warning 何かがおかしいと時(200 && response.body == nil), 509
		# @raise Error  クライアントエラー 400, 401, 403
		# @raise Fatal APIラッパーの修正が必要と思われるエラー, 404



		# 例:ティッカー
		# @param [String] pair 取得したい通貨ペア
		# @return [Hash]
		def ticker(pair)
			get('ticker', pair)
		end

# Private API


		# 未約定の注文一覧を取得します
		#  @param [String]    pair    トレードしたい通貨ペア
		#  @param [String]    action  注文の種類 ask(売)/bid(買)
		#  @param [Float]    price    注文価格(ただしBTC_JPYの時はInteger)
		#  @param [Float]    amount  注文量
		#  @param [Float]    limit    リミット注文価格(ただしBTC_JPYの時はInteger)
		# @return [Hash]
		def trade(pair, action, price, amount, limit = '')
			params = {
				currency_pair: pair,
				action:        action,
				price:         price,
				amount:        amount
			}
			params['limit'] = limit if limit != ''

			post('trade', params)
		end


#  Create request header & body

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
			request.set_form_data(params)  #クエリをURLエンコード (p1=v1&p2=v2...)
			request['Key']  = @key
			request['Sign'] = signature(request)

			res = do_command(uri, request)
			error_check(res)
			res
		end

		def delete(method)
			nonce = get_nonce.to_s
			uri = URI.parse "#{@private_url}#{method}"
			message = "#{nonce}#{uri.to_s}"
			sig = signature(message)
			header = headers(nonce, sig)
			request = Net::HTTP::Delete.new(uri.request_uri, headers)

			res = do_command(uri, request)
			error_check(res) #TODO check require
			res
		end

		def signature(req)
			algo = OpenSSL::Digest.new('sha512')
			OpenSSL::HMAC.hexdigest(algo, @secret, req.body)
		end

		def header(nonce, signature)
			{
				'Content-Type'	=> 'application/json',
				'ACCESS-KEY'		=> '@key,
				'ACCESS-NONCE'	=> nonce,
				'ACCESS-SIGNATURE'	=> signature
			}
		end

	end #of class
end #of Vexapion module
# :startdoc:

