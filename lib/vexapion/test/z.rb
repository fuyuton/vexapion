require 'vexapion/zaif'
require 'yaml'

local = true
public = true
priv = true

pair = 'btc_jpy'

home_dir = '/home/fuyuton'
key_file = "#{home_dir}/.key/test/zaif.yml"
key = YAML.load( File.read(key_file) )
api = Vexapion::Zaif.new(key['access-key'], key['secret-key'])

if local == true
			puts api.available_pair
end

if public == true
			puts api.last_price(pair)
			puts api.ticker(pair)
			puts api.trades(pair)
			puts api.depth(pair)
end

if priv == true
			puts api.get_info
			puts api.get_info2
			puts api.get_personal_info
			puts api.active_orders(pair = '')
			#puts api.trade(pair, action, price, amount, limit = '')
			#puts api.cancel_order(id)
			puts api.trade_history(pair)

			currency = 'btc'

			#puts api.withdraw(currency, amount, address, fee = nil, message = nil)

			puts api.deposit_history(currency)
			puts api.withdraw_history(currency)
end
