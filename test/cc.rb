require 'vexapion/coincheck'
require 'yaml'

public = true
priv = false

pair = 'btc_jpy'
key_file = "\~/.key/test/cc.yml"
#key_file = '/home/fuyuton/src/wcci/trade/coincheck/coincheck.yml'
keydata = File.read(key_file)
key = YAML.load(keydata)

api = Vexapion::API::Coincheck.new(key['access-key'], key['secret-key'])
begin

if public == true

			puts "api.ticker"
			puts api.ticker

			puts "api.trades"
			puts api.trades

			puts "api.order_books"
			puts api.order_books

end

			puts "api.balance"
			res = api.balance
			p res
			
			cur = 'JPY'
			amount = 1000
			puts "api.to_leverage(#{cur}, #{amount})"
			res = api.to_leverage(cur, amount)
			p res

			sleep 5
			puts "api.from_leverage(#{cur}, #{amount})"
			res = api.from_leverage(cur, amount)
			p res

if priv == true
			#puts "api.cancel(id)"
			#puts api.cancel(67928486)

			#現物買い
			rate = api.ticker['bid']
			amount = 0.001
			puts "api.order(pair, 'buy', rate, amount, stop_loss_rate = '')"
			b = api.order(pair, 'buy', rate, amount, stop_loss_rate = '')
			puts b
			sleep 5

			rate = (rate * 1.2).to_i
			amount = b['amount']
			#現物売り
			puts "api.order(pair, 'sell', rate, amount, stop_loss_rate = '')"
			s = api.order(pair, 'sell', rate, amount, stop_loss_rate = '')
			puts s

			#オーダー中のリスト
			puts "api.opens"
			puts api.opens

			puts "api.cancel(id)"
			puts api.cancel(s['id'])

			rate = api.ticker['ask']
			amount = b['amount']
			#現物売り
			puts "api.order(pair, 'sell', rate, amount, stop_loss_rate = '')"
			s = api.order(pair, 'sell', rate, amount, stop_loss_rate = '')
			puts s


			#現物成行買い
			puts "api.market_order(pair, 'buy', stop_loss_rate = '')"
			puts api.market_order(pair, 'buy', stop_loss_rate = '')
			
			#現物成行売り
			puts "api.market_order(pair, 'sell', amount, stop_loss_rate = '')"
			puts api.market_order(pair, 'sell', amount, stop_loss_rate = '')

			#レバレッジ買い
			rate = ticker['bid']
			amount = 0.001
			puts "api.leverage_order(pair, 'buy', rate, amount, stop_loss_rate = '')"
			leve = api.leverage_order(pair, 'buy', rate, amount, stop_loss_rate = '')
			puts leve
			sleep 5
			
			puts "api.position(params = {})"
			puts api.position()

			#レバレッジ返済
			pos_id = leve['id']
			amount = leve['amount']
			rate = ticker['ask']
			puts "api.close_position(close_position, position_id, rate, amount)"
			puts api.close_position(close_position, pos_id, rate, amount)

			#レバレッジ成行買い
			amount = 0.001
			puts "api.leverage_market_order(pair, 'buy', amount, stop_loss_rate = '')"
			leve = api.leverage_market_order(pair, 'buy', amount, stop_loss_rate = '')
			puts leve
			sleep 5

			puts "api.leverage_balance"
			puts api.leverage_balance

			#レバレッジ成行売り
			position_id = leve['id']
			amount = leve['amount']
			puts "api.close_position_market_order('long', position_id, amount)"
			puts api.close_position_market_order('long', position_id, amount)



			puts "api.transactions"
			puts api.transactions


			#puts "api.send_money(address, amount)"
			#puts api.send_money(address, amount)

			puts "api.send_history(currency = 'BTC')"
			puts api.send_history(currency = 'BTC')

			puts "api.deposit_history(currency = 'BTC')"
			puts api.deposit_history(currency = 'BTC')

			puts "api.deposit_accelerate(id)"
			puts api.deposit_accelerate(id)

			puts "api.account_info"
			puts api.account_info

			puts "api.bank_accounts"
			puts api.bank_accounts

			puts "api.regist_bank_account(bank, branch, type, number_str, name)"
			puts api.regist_bank_account(bank, branch, type, number_str, name)

			puts "api.delete_bank_account(id)"
			puts api.delete_bank_account(id)

			puts "api.bank_withdraw_history"
			puts api.bank_withdraw_history

			#puts "api.bank_withdraw(id, amount, currency = 'JPY', is_fast = false)"
			#puts api.bank_withdraw(id, amount, currency = 'JPY', is_fast = false)

			#puts "api.cancel_bank_withdraw(id)"
			#puts api.cancel_bank_withdraw(id)

			puts "api.borrow(amount, currency)"
			puts api.borrow(amount, currency)

			puts "api.borrow_list"
			puts api.borrow_list

			puts "api.repayment(id)"
			puts api.repayment(id)

			puts "api.to_leverage(amount, currency)"
			puts api.to_leverage(amount, currency)

			puts "api.from_leverage(amount, currency)"
			puts api.from_leverage(amount, currency)
end

rescue Vexapion::API::HTTPError=> e
	puts e.to_s
end
			puts "\n\nEnd of #{__FILE__} test.\n\n"
