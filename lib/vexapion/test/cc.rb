require 'vexapion/coincheck'
require 'yaml'

public = true
priv = false

pair = 'btc_jpy'

key_file = "key/cc.yml"
keydata = File.read(key_file)
key = YAML.load(keydata)

api = Vexapion::Coincheck.new(key['access-key'], key['secret-key'])
begin

if public == true

			#puts "api.ticker"
			#puts api.ticker

			puts "api.trades"
			puts api.trades

			#puts "api.order_books"
			#puts api.order_books

end

if priv == true

			puts "api.balance"
			res = api.balance
			p res
#------------------------------------------------------
			ask = api.ticker['ask'].to_i
			puts ask
			rate = (ask * 1.2).to_i
			amount = (1100.0 / rate).to_f.round(3)
			puts amount
			#現物売り
			#puts "api.order(#{pair}, 'sell', #{rate}, #{amount})"
			#s = api.order(pair, 'sell', rate, amount)
			#puts s

			#sleep 10
			#オーダー中のリスト
			puts "api.opens"
			res = api.opens
			puts res

			#orders = res['orders'][0]
			#puts orders
			#id = orders['id']
			#puts "api.cancel(#{id})"
			#puts api.cancel(id)

			#sleep 10

#------------------------------------------------------
			rate = api.ticker['bid'].to_i
			amount = (1100.0 / rate).round(3) - 2

			#現物売り
			#puts "api.order(#{pair}, 'sell', #{rate}, #{amount})"
			#s = api.order(pair, 'sell', rate, amount)
			#puts s

			#sleep 10

			#現物買い
			#rate = api.ticker['ask'].to_i
			#amount = api.balance['jpy'].to_i
			#puts "api.order(#{pair}, 'buy', #{rate}, #{amount})"
			#b = api.order(pair, 'buy', rate, amount)
			#puts b

#------------------------------------------------------

			#sleep 10
			rate = api.ticker['bid'].to_i
			amount = (1100 / rate).round(3)
			#現物成行売り
			#puts "api.market_sell(#{pair}, #{amount})"
			#puts api.market_sell(pair, amount)

			#sleep 10
			#amount_jpy = api.balance['jpy'].round - 100
			#現物成行買い
			#puts "api.market_buy(#{pair}, #{amount_jpy})"
			#puts api.market_buy(pair, amount_jpy)

#------------------------------------------------------

			cur = 'JPY'
			#amount = 1000
			#puts "api.to_leverage(#{cur}, #{amount})"
			#res = api.to_leverage(cur, amount)
			#p res
#------------------------------------------------------


			#レバレッジ買い
			rate = api.ticker['ask']
			amount = 0.01
			#puts "api.order_leverage(pair, 'buy', rate, amount)"
			#leve = api.order_leverage(pair, 'buy', rate, amount)
			#puts leve
			#sleep 30
			
			#puts "api.position('open')"
			#res = api.position
			#puts res
			#res['data'].each do |pos|
			#	#pos = res['data'][0]
			#	pos_id = pos['id']
			#	pos_rate = pos['open_rate']
			#	pos_side = pos['side']
			# amount = pos['amount']

			#	sleep 10
			#	tick = api.ticker
			# ask = tick['ask']
			#	bid = tick['bid']
			#	if pos_side.downcase == 'buy'
			#		posi = 'long'
					#bidが買ったときより高ければ レバレッジ返済
					#if pos_rate * 1.005 <= bid 
					#  puts "api.close_position_market_order(
					#				pair, #{posi}, #{pos_id}, #{amount})"
					#  puts api.close_position_market_order(pair, posi, pos_id, amount)
					#end
				#else
					#posi = 'short'

					#askが売ったときより安ければ レバレッジ返済
					#if ask <= pos_rate * 0.995
					#   puts "api.close_position_market_order(
					#				pair, #{posi}, #{pos_id}, #{amount})"
					#  puts api.close_position_market_order(pair, posi, pos_id, amount)
					#end
				#end

				#レバレッジ返済
				#puts "api.close_position_market_order(pair, long, #{pos_id}, #{amount})"
				#puts api.close_position_market_order(pair, 'long', pos_id, amount)

			#end
			#レバレッジ成行買い
			#amount = 0.005
			#puts "api.market_order_leverage(pair, 'buy', amount, stop_loss_rate = '')"
			#leve = api.market_order_leverage(pair, 'buy', amount, stop_loss_rate = '')
			#puts leve
			#sleep 10

			puts "api.leverage_balance"
			puts api.leverage_balance

			#レバレッジ成行売り
			#position_id = leve['id']
			#amount = leve['amount']
			#puts "api.close_position_market_order(pair, 'long', position_id, amount)"
			#puts api.close_position_market_order(pair, 'long', position_id, amount)


			#sleep 5
			#bal = api.leverage_balance
			#puts bal
			#amount = bal['margin']['jpy']
			#puts "api.from_leverage(#{cur}, #{amount})"
			#res = api.from_leverage(cur, amount)
			#p res

#------------------------------------------------------

			puts "api.transactions"
			puts api.transactions


			#puts "api.send_money(address, amount)"
			#puts api.send_money(address, amount)

			puts "api.send_history(currency = 'BTC')"
			puts api.send_history(currency = 'BTC')

			puts "api.deposit_history(currency = 'BTC')"
			puts api.deposit_history(currency = 'BTC')

			#puts "api.deposit_accelerate(id)"
			#puts api.deposit_accelerate(id)

			puts "api.accounts"
			puts api.accounts

			puts "api.bank_accounts"
			puts api.bank_accounts

			#puts "api.regist_bank_account(bank, branch, type, number_str, name)"
			#puts api.regist_bank_account(bank, branch, type, number_str, name)

			#puts "api.delete_bank_account(id)"
			#puts api.delete_bank_account(id)

			puts "api.bank_withdraw_history"
			puts api.bank_withdraw_history

			#puts "api.bank_withdraw(id, amount, currency = 'JPY', is_fast = false)"
			#puts api.bank_withdraw(id, amount, currency = 'JPY', is_fast = false)

			#puts "api.cancel_bank_withdraw(id)"
			#puts api.cancel_bank_withdraw(id)

			#puts "api.borrow(amount, currency)"
			#puts api.borrow(amount, currency)

			puts "api.borrow_list"
			puts api.borrow_list

			#puts "api.repayment(id)"
			#puts api.repayment(id)

end

rescue Vexapion::HTTPError=> e
	puts e.to_s
end
			puts "\n\nEnd of #{__FILE__} test.\n\n"
