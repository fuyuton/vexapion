require 'vexapion/poloniex'
require 'yaml'
require 'json'

key_file = "key/polo.yml"
file = File.read(key_file)
key = YAML.load(file)
api = Vexapion::Poloniex.new(key['access-key'], key['secret-key'])
pair = 'USDT_LTC'

			mkt = 'BTC'
			asset = 'LTC'
			pair = "#{mkt}_#{asset}"

			puts "api.ticker"
			res = api.ticker
			ask = res[pair]['lowestAsk'].to_f
			bid = res[pair]['highestBid'].to_f
			puts "ask: %10.8f bid:%10.8f"%[ask, bid]
			
			
			res = api.complete_balances
			mkt_amount = res[mkt]['available'].to_f
			asset_amount = res[asset]['available'].to_f
			puts "%s: %12.8f %s: %12.8f"%[mkt, mkt_amount, asset, asset_amount]

			amount = 0.05

			puts "api.sell(#{pair}, #{ask+10}, #{amount})"
			res = api.sell(pair, ask+10, amount)
			puts res
			order_number = res['orderNumber']
			sleep 0.5

			puts "api.move_order(#{order_number}, #{ask})"
			res = api.move_order(order_number, ask)
			puts res
			order_number = res['orderNumber']
			puts order_number
			sleep 0.5

			puts "api.cancel_order(#{order_number})"
			puts api.cancel_order(order_number)


			res = api.ticker
			ask = res[pair]['lowestAsk'].to_f
			bid = res[pair]['highestBid'].to_f
			puts "ask: %10.8f bid:%10.8f"%[ask, bid]

			puts "api.sell(#{pair}, #{bid}, #{amount})"
			res = api.sell(pair, bid, amount)
			puts res
			order_number = res['order_number']
			sleep 3


			res = api.available_account_balances
			amount = (res['exchange'][mkt].to_f / ask).round(3)
			puts "api.buy(#{pair}, #{ask}, #{amount})"
			res = api.buy(pair, ask, amount)
			puts res


			mkt = 'BTC'
			asset = 'STR'
			pair = "#{mkt}_#{asset}"

			res = api.ticker
			ask = res[pair]['lowestAsk'].to_f
			bid = res[pair]['highestBid'].to_f
			puts "ask: %10.8f bid:%10.8f"%[ask, bid]
			amount = 1000
			buy_rate = bid

			puts 'api.margin_sell(#{pair}, #{buy_rate}, #{amount})'
			res = api.margin_sell(pair, buy_rate, amount)
			puts res
			sleep 15

			res = api.complete_balances
			mkt_amount = res[mkt]['available'].to_f
			asset_amount = res[asset]['available'].to_f
			puts "%s: %12.8f %s: %12.8f"%[mkt, mkt_amount, asset, asset_amount]

			res = api.ticker
			ask = res[pair]['lowestAsk'].to_f
			bid = res[pair]['highestBid'].to_f
			puts "ask: %10.8f bid:%10.8f"%[ask, bid]

			#flag = true
			#while flag
				#if ask <= buy_rate * 0.998
		  	  puts 'api.margin_buy(#{pair}, #{ask}, #{amount})'
		  	  res = api.margin_buy(pair, ask, amount)
				  puts res
					flag = false

				#end
				sleep 1
			  res = api.ticker
			  ask = res[pair]['lowestAsk'].to_f
			  bid = res[pair]['highestBid'].to_f

			#end
			puts 'api.margin_account_summary'
			puts api.margin_account_summary

			puts 'api.available_account_balances'
			puts api.available_account_balances

			currency = 'LTC'
			amount = 1
			from_account = 'Margin'
			to_account = 'Exchange'
			puts "api.transfer_balance(#{currency}, #{amount},
				#{from_account.downcase}, #{to_account.downcase})"
			puts api.transfer_balance(currency, amount,
				from_account.downcase, to_account.downcase)



			#puts "api.withdraw(currency, amount, address)"
			#puts api.withdraw(currency, amount, address)

