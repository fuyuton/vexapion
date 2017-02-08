require 'vexapion/bitflyer'
require 'yaml'

pair1 = 'BTC_JPY'
pair2 = 'BTC_JPY'

home_dir = "/home/fuyuton"
key_file = "#{home_dir}/.key/test/bf.yml"
file = File.read(key_file)
key = YAML.load(file)

api = Vexapion::Bitflyer.new(key['access-key'], key['secret-key'])
#api = Vexapion::Bitflyer.new

public = true
priv = true

res = api.ticker(pair1)
#puts res
ask = res['best_ask']
bid = res['best_bid']

type = 'LIMIT'
side = 'sell'
price = 140000
amount = 0.001
#puts "api.send_child_order(pair1, type, side, price, size)"
#res = api.send_child_order(pair1, type, side, price, amount)
#coaid = res['child_order_acceptance_id']
#p coaid

#sleep 5

#puts "cancel"
#res = api.cancel_child_order_acceptance_id(pair1, coaid)
#p res

puts 'order'
puts api.send_child_order(pair1, type, side, price, amount)
sleep 3
puts 'get_orders'
res = api.get_child_orders(pair1)
puts res
oid = res[0]['child_order_id']
puts oid
puts "cancel"
res = api.cancel_all_child_order(pair1)
#res = api.cancel_child_order_id(pair1, oid)
puts res


if public == true
			puts "\n\napi.board(#{pair1})"
			puts api.board(pair1)

			puts "\n\napi.ticker(#{pair1})"
			puts api.ticker(pair1)


			puts "\n\napi.get_public_executions(pair1, count=100, before=0, after=0)"
			puts api.get_public_executions(pair1, count=100, before=0, after=0)

			#puts "\n\napi.get_chats(date)"
			#puts api.get_chats(date)

			puts "\m\bapi.get_health"
			puts api.get_health
end


if priv == true
			puts "\napi.get_permissions"
			puts JSON.pretty_generate(api.get_permissions)

			puts "api.get_balance"
			res = api.get_balance
			puts JSON.pretty_generate(res)

			puts "api.get_collateral"
			puts api.get_collateral

			puts "api.get_addresses"
			puts api.get_addresses

			puts "api.executions(pair1, count=100, before=0, after=0)"
			puts api.executions(pair1, count=100, before=0, after=0)

			puts "api.get_coin_ins(count=100, before=0, after=0)"
			puts api.get_coin_ins(count=100, before=0, after=0)

			#puts "api.sendcoin(currency, amount, address, fee=0.0, code='')"
			#puts api.sendcoin(currency, amount, address, fee=0.0, code='')

			puts "api.get_coin_outs(count=100, before=0, after=0)"
			puts api.get_coin_outs(count=100, before=0, after=0)

			#puts "api.get_coin_outs_id(id)"
			#puts api.get_coin_outs_id(id)

			puts "api.get_bank_accounts"
			puts api.get_bank_accounts

			puts "api.get_deposits(count=100, before=0, after=0)"
			puts api.get_deposits(count=100, before=0, after=0)

			#puts "api.withdraw(currency, id, amount, code='')"
			#puts api.withdraw(currency, id, amount, code='')

			puts "api.get_withdrawals(count=100, before=0, after=0)"
			puts api.get_withdrawals(count=100, before=0, after=0)
#-------------------------------------------------------------------
			puts "api.get_executions(pair1, count=100, before=0, after=0, child_order_id='', child_order_acceptance_id='')"
			puts api.get_executions(pair1, count=100, before=0, after=0, child_order_id='', child_order_acceptance_id='')

			puts "api.get_positions"
			puts api.get_positions
#-------------------------------------------------------------------

			#puts "api.send_child_order(pair1, type, side, price, size)"
			#puts api.send_child_order(pair1, type, side, price, size)

			#puts "api.cancel_child_order(pair1, order_id='')"
			#puts api.cancel_child_order(pair1, order_id='')

			#puts "api.cancel_child_order_id(pair1, order_id)"
			#puts api.cancel_child_order_id(pair1, order_id)

			#puts "api.cancel_child_order_acceptance_id(pair1, acceptance_id)"
			#puts api.cancel_child_order_acceptance_id(pair1, acceptance_id)

			#puts "api.send_parent_order(params)"
			#puts api.send_parent_order(params)

			#puts "api.cancel_parent_order_id(pair1, order_id)"
			#puts api.cancel_parent_order_id(pair1, order_id)

			#puts "api.cancel_parent_order_acceptance_id(pair1, acceptance_id)"
			#puts api.cancel_parent_order_acceptance_id(pair1, acceptance_id)

			#puts "api.cancel_all_child_order(pair1)"
			#puts api.cancel_all_child_order(pair1)

			#puts "api.get_child_orders(pair1, count=100, before=0, after=0, state='', pid='')"
			#puts api.get_child_orders(pair1, count=100, before=0, after=0, state='', pid='')

			puts "api.get_parent_orders(pair1, count=100, before=0, after=0, state='')"
			puts api.get_parent_orders(pair1, count=100, before=0, after=0, state='')

			#puts "api.get_parent_order(parent_order_id)"
			#puts api.get_parent_order(parent_order_id)

			#puts "api.get_parent_order(acceptance_id)"
			#puts api.get_parent_order(acceptance_id)

end #of private

	puts "\n\nEnd of #{__FILE__} test\n\n"
