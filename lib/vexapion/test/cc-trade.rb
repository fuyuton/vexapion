require 'vexapion/coincheck'
require 'yaml'

pair = 'btc_jpy'
key_file = "key/cc.yml"
keydata = File.read(key_file)
key = YAML.load(keydata)

api = Vexapion::Coincheck.new(key['access-key'], key['secret-key'])
begin

	bal = api.leverage_balance
	puts bal
	amount = bal['margin']['jpy'].to_i
	puts "move to_leverage #{amount}JPY"
	res = api.to_leverage(cur, amount)


#------------------------------------------------------

	cur = 'JPY'

#レバレッジ買い
	rate = api.ticker['ask']
	amount = 0.01
	puts "api.order_leverage(pair, 'buy', rate, amount)"
	leve = api.order_leverage(pair, 'buy', rate, amount)
	puts leve
	sleep 30

#ポジ解消
	puts "api.position('open')"
	res = api.position('open')
	#puts res
while res['data'] != []
	res['data'].each do |pos|
		#pos = res['data'][0]
		pos_id = pos['id'].to_i
		pos_rate = pos['open_rate'].to_i
		pos_side = pos['side']
		amount = pos['amount'].to_f
		puts " #{pos_id} #{pos_rate} #{pos_side} #{amount} "

		sleep 1
		tick = api.ticker
		ask = tick['ask'].to_i
		bid = tick['bid'].to_i

		if pos_side.downcase == 'buy'
			posi = 'long'
			#bidが買ったときより高ければ
			if pos_rate < bid 
			  puts "(#{posi}, #{pos_id}, #{amount}) #{ask} #{bid}"
			  puts api.close_position_market_order(pair, posi, pos_id, amount)
			end
			#askが買ったときより安ければ
			if ask < pos_rate
			  puts "(#{posi}, #{pos_id}, #{amount}) #{ask} #{bid}"
			  puts api.close_position_market_order(pair, posi, pos_id, amount)
			end
		end
		if pos_side.downcase == 'sell'
			posi = 'short'
			#bidが売ったときより安ければ
			if bid < pos_rate
			  puts "(#{posi}, #{pos_id}, #{amount}) #{ask} #{bid}"
			  puts api.close_position_market_order(pair, posi, pos_id, amount)
			end
			#askが売ったときより高ければ
			if pos_rate < ask
			  puts "(#{posi}, #{pos_id}, #{amount}) #{ask} #{bid}"
			  puts api.close_position_market_order(pair, posi, pos_id, amount)
			end
		end
	end
	res = api.position('open')
end #while

rescue Vexapion::HTTPError=> e
	puts e.to_s
end
			puts "\n\nEnd of #{__FILE__} test.\n\n"
