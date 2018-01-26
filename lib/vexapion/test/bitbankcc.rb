require 'vexapion/bitbankcc'
require 'bigdecimal'
require 'yaml'
require 'json'

key_file = "key/bitbank.yml"
keydata = File.read(key_file)
key = YAML.load(keydata)

api = Vexapion::Bitbankcc.new(key['access-key'], key['secret-key'])

public = false
priv = true
trade = false
cancel = false #true


pair = 'btc_jpy'
pairs = ['btc_jpy', 'xrp_jpy', 'ltc_btc', 'eth_btc', 'mona_jpy', 'mona_btc', 'bcc_jpy', 'bcc_btc']

if public
		res = api.ticker(pair: pair)
		puts JSON.pretty_generate(res)
		btcjpy = res['data']
		pairs.each do |pair|
			t1 = Time.now.to_f
			#res = api.ticker(pair:pair)
			t2 = Time.now.to_f
			data = res['data'] if res['success'] == 1
			restime = BigDecimal(t2.to_s)-BigDecimal(t1.to_s)
			pa = pair.split('_')
			sell = pa[1] == 'jpy' ? data['sell'].to_f : data['sell'].to_f * btcjpy['buy'].to_f
			buy = pa[1] == 'jpy' ? data['buy'].to_f : data['buy'].to_f * btcjpy['sell'].to_f
			#puts "#{pair}/  ask: #{sell} bid: #{buy} response time:#{restime}"
		end
		res = api.transactions(pair:pair)# , date: Time.now.strftime("%Y%m%d"))
		#puts JSON.pretty_generate(res)
		#puts api.candlestick(pair:pair , span: '1min', date: Time.local(2017, 11, 3, 0,0,0).strftime("%Y%m%d"))
		res = api.depth(pair: pair)
		#puts JSON.pretty_generate(res)
end

if priv 
		pair = 'mona_btc'
		puts JSON.pretty_generate(api.assets)
		##puts api.get_order(pair:pair, order_id:)
		#puts api.order(pair:pair, amount:, price:, side:, type:)
		##puts api.cancel_order(pair:pair, order_id:)
		##puts api.cancel_orders(pair:pair, order_ids:)
		#puts api.orders_info(pair: pair, order_ids:)
		#puts 'active_orders'
		#puts api.active_orders(pair:pair, count: 10, from_id: nil, end_id: nil, since: nil, i_end: nil)
		#puts api.withdrawal_account(asset:)
		#puts api.request_withdrawal(asset:, uuid:, amount:, otp_token: '', sms_token: '')
		#puts 'trade_history'
		#puts api.trade_history(pair: pair)
end

if trade
	pair = 'mona_btc'
	tick = api.ticker(pair: pair)
	depth = api.depth(pair: pair)
	price = depth['data']['asks'][0][0].to_i + 10000
	#amount =  depth['data']['asks'][0][1].to_f
	amount = 1 #amount < 10.0 ? 10.0 : amount
	puts "sell price: #{price}, amount: #{amount}"
	puts api.order(pair:pair, amount: amount, price: price, side: 'sell', type:'limit')
end

if cancel
	pair = 'mona_btc'
	res = api.active_orders(pair:pair)
	p res
	orders = res['data']['orders']
	orders.each do |elem|
		puts "order_id: #{elem['order_id']}"
		puts api.cancel_order(pair: pair, order_id: elem['order_id'])
	end
end
