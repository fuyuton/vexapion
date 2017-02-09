require 'vexapion/bitflyer'
require 'yaml'

@pair = 'BTC_JPY'
pair2 = 'BTC_JPY'

key_file = "key/bf.yml"
file = File.read(key_file)
key = YAML.load(file)

@api = Vexapion::Bitflyer.new(key['access-key'], key['secret-key'])

public = true
priv = true

res = @api.ticker(@pair)
ask = res['best_ask']
bid = res['best_bid']

@type = 'LIMIT'
side = 'SELL'
price = 140000
amount = 0.001

#puts "@api.send_child_order(@pair, @type, side, price, size)"
#res = @api.send_child_order(@pair, @type, side, price, amount)
#coaid = res['child_order_acceptance_id']
#p coaid

#sleep 5

#puts "cancel"
#res = @api.cancel_child_order_acceptance_id(@pair, coaid)
#p res

#puts 'order'
#puts @api.send_child_order(@pair, @type, side, price, amount)
#sleep 3
#puts 'get_orders'
#res = @api.get_child_orders(@pair)
#puts res
#oid = res[0]['child_order_id']
#puts oid
#puts "cancel"
#res = @api.cancel_all_child_order(@pair)
#res = @api.cancel_child_order_id(@pair, oid)
#puts res

def buy(price, size)
	puts "@api.send_child_order(@pair, @type, 'BUY', price, size)"
	res = @api.send_child_order(@pair, @type, 'BUY', price.to_i, size.to_f)
	puts res
	res['child_order_acceptance_id']
end

def sell(price, size)
	puts "@api.send_child_order(@pair, @type, 'SELL', price, size)"
	res = @api.send_child_order(@pair, @type, 'SELL', price.to_i, size.to_f)
	puts res
	res['child_order_acceptance_id']
end

def tick
	res = @api.ticker(@pair)
	ask = res['best_ask'].to_i
	bid = res['best_bid'].to_i
	{ ask: ask, bid: bid }
end

def balance
	res = @api.get_balance
	lst = Hash.new
	ret = Hash.new
	res.each do |asset|
		name = asset['currency_code']
		amount = asset['amount']
		available = asset['available']
		lst[name] = {
			amount: amount,
			available: available
		}
		ret.update lst
	end
	ret
end

#------------------------------------------------------------------
#残高取得
	res = balance
	jpy_avail = res['JPY']['available']
	btc_avail = res['BTC']['available']

#売る
puts '\n\nsell'
	amount = 0.001 
	rate = tick[:ask] + 5000
	res = sell(rate, amount)
	sleep 4

#注文リスト表示
	puts "\n@api.get_child_orders(@pair)"
	res = @api.get_child_orders(@pair, "ACTIVE")
	puts res
	order_id = res[0]['child_order_id']
	puts "\n\n#{order_id}"

	sleep 10
#キャンセル
	puts "\n@api.cancel_child_order(#{@pair}, #{order_id})"
	puts @api.cancel_child_order(@pair, order_id)
	sleep 3

#売る

	res = sell(rate, amount)
	puts res
	acceptance_id =  res

	sleep 4
#きゃんせる
			puts "\n@api.cancel_child_order_acceptance_id(@pair, acceptance_id)"
			puts @api.cancel_child_order_specify_acceptance_id(@pair, acceptance_id)

#売る

	sell(rate, amount)

	sleep 4
#きゃんせる
			puts "\n@api.cancel_all_child_order(@pair)"
			puts @api.cancel_all_child_order(@pair)

#売る
	rate = tick[:bid]
	sell(rate, amount)

#買い戻す
	rate = tick[:ask]
	buy(rate, amount)
#------------------------------------------------------------------
# parent order ??

			#puts "@api.send_parent_order(params)"
			#puts @api.send_parent_order(params)

			#puts "@api.get_parent_orders(@pair)"
			#puts @api.get_parent_orders(@pair)

			#puts "@api.get_parent_order(parent_order_id)"
			#puts @api.get_parent_order(parent_order_id)

			#puts "@api.get_parent_order(acceptance_id)"
			#puts @api.get_parent_order(acceptance_id)

			#puts "@api.cancel_parent_order_id(@pair, order_id)"
			#puts @api.cancel_parent_order_id(@pair, order_id)

			#puts "@api.cancel_parent_order_acceptance_id(@pair, acceptance_id)"
			#puts @api.cancel_parent_order_acceptance_id(@pair, acceptance_id)

#-------------------------------------------------------------------

			#puts "\n\n@api.get_chats(date)"
			#puts @api.get_chats(date)

#-------------------------------------------------------------------

			# 払出
			#puts "@api.sendcoin(currency, amount, address, fee, code)"
			#puts @api.sendcoin(currency, amount, address, fee, code)

			#puts "@api.withdraw(currency, id, amount, code)"
			#puts @api.withdraw(currency, id, amount, code)


puts "\n\nEnd of #{__FILE__} test\n\n"
