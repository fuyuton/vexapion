# coding: utf-8

require 'vexapion'

#@author @fuyuton fuyuton@pastelpink.sakura.ne.jp
module Vexapion
    
	# bittrexのAPIラッパークラスです
	# 各メソッドの戻り値は下記URLを参照してください
	# @see https://

	class Bittrex < BaseExchanges

		#@api private
		def initialize(key = nil, secret = nil)
			super(key, secret)

			@public_url = 'https://bittrex.com/api/v1.1/public/'
			@market_url = 'https://bittrex.com/api/v1.1/market/'
			@account_url = 'https://bittrex.com/api/v1.1/account/'

			set_min_interval(1)

			#@available_pair = ['BTC_JPY', 'FX_BTC_JPY', 'ETH_BTC']
		end

# Public APIs
		#ペア情報
		# @return [Hash]
		def getmarkets
			public_get('getmarkets')
		end

		#取扱通貨情報
		# @return [Hash]
		def getcurrencies
			public_get('getcurrencies')
		end

		#ティッカー
		# @param [String] market ペア
		# @return [Hash]
		def getticker(market:)
			public_get('getticker', market:market)
		end

		#マーケット情報(一括)
		# @return [Hash]
		def getmarketsummaries
			public_get('getmarketsummaries')
		end

		#マーケット情報(指定ペア)
		# @param [String] market ペア
		# @return [Hash]
		def getmarketsummary(market:)
			public_get('getmarketsummary', market:market)
		end

		#板情報
		# @param [String] market ペア
		# @param [String] type	'buy', 'sell', 'both'
		# @return [Hash]
		def getorderbook(market:, type:'both')
			public_get('getorderbook', market:market, type:type)
		end

		#マーケット履歴
		# @param [String] market ペア
		# @return [Hash]
		def getmarkethistory(market:)
			public_get('getmarkethistory', market:market)
		end

#Market APIs

		#buylimit
		# @param [String] market ペア
		# @param [float] quantity 量
		# @param [float] rate レート
		# @return [Hash]
		def buylimit(market:, quantity:, rate:)
			get('market/buylimit', market:market, quantity:quantity, rate:rate)
		end

		#selllimit
		# @param [String] market ペア
		# @param [float] quantity 量
		# @param [float] rate レート
		# @return [Hash]
		def selllimit(market:, quantity:, rate:)
			get('market/selllimit', market:market, quantity:quantity, rate:rate)
		end

		#cancel
		# @param [String] uuid ORDER_UUID
		# @return [Hash]
		def cancel(uuid:)
			get('market/cancel', uuid:uuid)
		end

		#getopenorders
		# @param [String] market ペア
		# @return [Hash]
		def getopenorders(market:)
			get('market/getopenorders', market:market)
		end

#Account APIs

		#getbalances
		# @return [Hash]
		def getbalances
			get('account/getbalances')
		end

		#getbalance
		# @param [String] currency 通貨略称
		# @return [Hash]
		def getbalance(currency:)
			get('account/getbalance', currency:currency)
		end

		#getdepositaddress
		# @param [String] currency 通貨略称
		# @return [Hash]
		def getdepositaddress(currency:)
			get('account/getdepositaddress', currency:currency)
		end

		#withdraw
		# @param [String] currency 通貨略称
		# @param [float] quantity 量
		# @param [String] address 宛先アドレス
		# @param [String] paymentid optional used for CryptoNotes/BitShareX/Nxt optional field(memo/paimentid)
		# @return [Hash]
		def withdraw(currency:, quantity:, address:, paymentid:'')
			get('account/withdraw', currency:currency, quantity:quantity, address:address, paymentid:paymentid)
		end

		#getorder
		# @param [String] uuid ORDER_UUID
		# @return [Hash]
		def getorder(uuid:'')
			get('account/getorder',uuid:uuid)
		end

		#getorders
		# @param [String] uuid ORDER_UUID
		# @return [Hash]
		def getorders
			get('account/getorders')
		end

		#getorderhistory
		# @option [String] market ペア
		# @return[Hash]
		def getorderhistory(market: '')
			get('account/getorderhistory', market:market)
		end

		#getwithdrawalhistory
		# @option [String] currency 通貨略称
		# @return[Hash]
		def getwithdrawalhistory(currency: '')
			get('account/getwithdrawalhistory', currency:currency)
		end
		
		#getdeposithistory
		# @option [String] currency 通貨略称
		# @return[Hash]
		def getdeposithistory(currency: '')
			get('account/getdeposithistory', currency:currency)
		end


# Create request header & body

		private 
		
		#@api private
		def public_get(command, params={})
			uri = URI.parse "#{@public_url}#{command}"
			uri.query = URI.encode_www_form(params)
			request = Net::HTTP::Get.new(uri.request_uri)
			#request.set_form_data(params) #クエリをURLエンコード(p1=v1&p2=v2...)

			do_command(uri, request)
		end

		#@api private
		def get(command, query={})
			method = 'GET'
			uri = URI.parse "#{@private_url}#{command}"
			puts uri
			query['apikey'] = @key
			query['nonce']	= get_nonce.to_s
			#puts "query: #{query}"
			uri.query = URI.encode_www_form(query)
			text = "#{uri}"
			sign = signature(text)
			header = headers(sign)

			request = Net::HTTP::Get.new(uri.request_uri, header)

			do_command(uri, request)
		end

		#@api private
		#def post(command, params={})
		#	method = 'POST'
		#	uri = URI.parse "#{@private_url}#{command}"
		#	timestamp = get_nonce.to_s
		#	body = params.to_json #add
#
#			text = "#{timestamp}#{method}#{uri.request_uri}#{body}"
#			sign = signature(text)
#			header = headers(sign, timestamp)
#			request = Net::HTTP::Post.new(uri.request_uri, header)
#			request.body = body
#
#			res = do_command(uri, request)
#			#error_check(res)
#			res
#		end

		#@api private
		def signature(data)
			algo = OpenSSL::Digest.new('sha512')
			OpenSSL::HMAC.hexdigest(algo, @secret, data)
		end

		#@api private
		def headers(sign)
			{
				'apisign'       => sign,
			}
		end

		#@api private
		#def pagenation(count, before, after)
		#	params = Hash.new
		#	params.merge!( count: count ) unless count.nil?
		#	params.merge!( before: before ) unless before.nil?
		#	params.merge!( after: after ) unless after.nil?
		#	params
		#end

		#@api private
		def error_check(res)
			if !res.nil? && res['success'] == 0 && res.has_key?('error')
				raise Warning.new(0, res['error'])
			end
		end

	end #of class
end #of module
