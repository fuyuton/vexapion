require 'vexapion/poloniex'
require 'yaml'

home_dir = "/home/fuyuton"
key_file = "#{home_dir}/.key/test/polo.yml"
file = File.read(key_file)
key = YAML.load(file)
api = Vexapion::Poloniex.new(key['access-key'], key['secret-key'])
pair = 'ltc_usdt'

public = false
priv = false

			puts "api.ticker"
			puts api.ticker

if public == true
			puts "api.volume_24hours"
			puts api.volume_24hours
			puts "api.ticker"
			puts api.ticker
			puts "api.orderbook(pair, depth)"
			puts api.orderbook(pair, depth)
			puts "api.market_trade_history(pair)"
			puts api.market_trade_history(pair)
			puts "api.fee_info"
			puts api.fee_info
end
			puts "api.balances"
			puts api.balances

if priv == true
			puts api.balances
			puts api.balances

			puts api.complete_balances
			puts api.complete_balances

			puts api.open_orders(pair)
			puts api.open_orders(pair)

			puts api.trade_history(pair, start, end_time)
			puts api.trade_history(pair, start, end_time)

			puts api.buy(pair, rate, amount)
			puts api.buy(pair, rate, amount)

			puts api.sell(pair, rate, amount)
			puts api.sell(pair, rate, amount)

			puts api.cancel_order(order_number)
			puts api.cancel_order(order_number)

			puts api.move_order(order_number, rate)
			puts api.move_order(order_number, rate)

			puts api.withdraw(currency, amount, address)
			puts api.withdraw(currency, amount, address)

			puts api.available_account_balances
			puts api.available_account_balances

			puts api.tradable_balances
			puts api.tradable_balances

			puts api.transfer_balance(currency, amount, from_ccount, to_account)
			puts api.transfer_balance(currency, amount, from_ccount, to_account)

			puts api.margin_account_summary
			puts api.margin_account_summary

			puts api.margin_buy(pair, rate, amount)
			puts api.margin_buy(pair, rate, amount)

			puts api.margin_sell(currency_pair, rate, amount)
			puts api.margin_sell(currency_pair, rate, amount)

			puts api.deposit_addresses
			puts api.deposit_addresses

			puts api.generate_new_address(currency)
			puts api.generate_new_address(currency)

			puts api.deposits_withdrawals(start_time, end_time, count)
			puts api.deposits_withdrawals(start_time, end_time, count)

end


