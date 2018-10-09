require 'vexapion/bitstamp'
require 'yaml'

public = true
priv = false

pair = 'btcusd'

api = Vexapion::Bitstamp.new

if public == true
		#res = api.ticker(pair:pair)
		#res = api.ticker_hour(pair:pair)
		#res = api.order_book(pair:pair)
		#res = api.transactions(pair:pair, time:nil)
		#res = api.trading_pairs_info
		res = api.eur_usd
		puts res
end

if priv == true
end
