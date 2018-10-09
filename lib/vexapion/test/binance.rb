require	'vexapion/binance'
require 'yaml'

key_file = 'key/binance.yml'
file = File.read(key_file)
key = YAML.load(file)
api = Vexapion::Binance.new(key['access-key'], key['secret-key'])

pair = 'LTCBTC'
public = true
priv = false
wapi = false
stream = false

if public == true
		#puts api.ping
		#puts api.time
		p 'exchange_info'
		res = api.exchange_info
		#res['symbols'].each do |data|
			#price = data['filters'][0]
			#lot = data['filters'][1]
			#print "%9s "%[data['symbol']]
			#print "#{price['minPrice']} #{price['tickSize']} #{price['maxPrice']} "
			#puts "#{lot['minQty']} #{lot['stepSize']} #{lot['maxQty']}"
		#end
		#puts res

		#p api.exchange_info

		p 'depth'
		#p api.depth(symbol: pair, limit: nil)
		
		p 'trades'
		#p api.trades(symbol: pair , limit: nil)

		#puts api.historical_trades(symbol: pair, limit: nil, from_id: nil)
		#puts api.agg_trades(symbol: pair, from_id: nil, start_time: nil, end_time: nil, limit: nil)
		#puts api.klines(symbol: pair, interval: '5m', limit: nil, start_time: nil, end_time: nil)
		#puts api.twenty_four_hour(symbol: pair)
		#puts api.price(symbol: pair)
		puts api.book_ticker#(symbol: pair)

		t1 = Time.now.to_f
		p 'book_ticker'
		#p api.book_ticker
		t2 = Time.now.to_f
		#puts BigDecimal(t2.to_s) - BigDecimal(t1.to_s)

end

if priv == true
	begin
		puts "account information"
		p api.account_information
		#puts "query_order"
		#puts api.query_order(symbol: pair)
		puts "all_orders"
		p api.all_orders(symbol: pair)
		puts "my_trades"
		p api.my_trades(symbol: pair)

		#puts api.order_test
		#puts 'order'
		#res = api.order(symbol: pair, side: 'buy', type: 'LIMIT', time_in_force: 'GTC', quantity: 1, price: 0.008)
		#puts res

		#puts 'open_orders'
		#res = api.open_orders(symbol: pair)
		#p res
		#id = res[0]['orderId'] if !res.empty?
		#puts id

		#puts 'cancel'
		#puts api.cancel(symbol: pair, order_id: id.to_i)

	rescue Vexapion::Warning => e
		puts "code:#{e.code} msg:#{e.msg}"
	rescue Vexapion::Error => e
		#puts e,"code:#{e.code} msg:#{e.msg}"
		puts e
	end
end

if stream == true
		#puts api.open_stream
		#puts api.keepalive_stream(listen_key:)
		#puts api.close_stream(listen_key:)
end

if wapi == true
	begin
		#puts api.withdraw(asset:, address:, amount:, )
		#puts api.deposit_history(asset: nil, status: nil, start_time: nil, end_time: nil)
		#puts api.withdraw_history(asset: nil, status: nil, start_time: nil, end_time: nil)
		#puts api.deposit_address(asset:)
		puts api.account_status
		puts api.system_status
	rescue Vexapion::Warning => e
		puts "code:#{e.code} msg:#{e.msg}"
	end
end
