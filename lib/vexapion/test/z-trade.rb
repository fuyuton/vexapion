require 'vexapion'
require 'yaml'

@pair = 'xem_jpy'

key_file = "key/zaif.yml"
key = YAML.load( File.read(key_file) )
@api = Vexapion::Zaif.new(key['access-key'], key['secret-key'])

def ticker
	res = @api.ticker(@pair)
	ask = res['ask']
	bid = res['bid']
	{ ask: ask, bid: bid }
end

def balance
	res = @api.get_info2
	funds = res['return']['funds']
	avail = Hash.new
	avail['jpy'] = funds['jpy']
	avail['btc'] = funds['btc']
	avail['xem'] = funds['xem']

	avail
end

tick = ticker
avail = balance

price = (tick[:ask] * 1.1).round(4)
puts "price: #{avail}"
amount = 100
puts "\nxem_jpy: ask: %6.4f / amount: %6.1f"%[price, amount]

puts "@api.trade(#{@pair}, 'ask', #{price.to_f}, #{amount.to_f})"
res = @api.trade(@pair, 'ask', price.to_f, amount.to_f) #, tick[:bid].to_f)
puts res

res = @api.active_orders(@pair)
puts ""
puts res
id = ''
res['return'].each do |k, v|
	id = k
end
puts id
sleep 10
res = @api.cancel_order(id)
puts res

res = @api.trade_history(@pair)
puts res


currency = 'btc'
res = @api.deposit_history(currency)
puts res
res = @api.withdraw_history(currency)
puts res

#res = @api.withdraw(currency, amount, address, fee, message)
#puts res

