require 'vexapion/zaif'
require 'yaml'

public = false
priv = true

pair = 'btc_jpy'

key_file = "key/zaif.yml"
key = YAML.load( File.read(key_file) )
api = Vexapion::Zaif.new(key['access-key'], key['secret-key'])

if public == true
			puts api.last_price(pair)
			puts api.ticker(pair)
			#puts api.trades(pair)
			puts api.depth(pair)
			puts JSON.pretty_generate(api.currency_pairs)
			puts JSON.pretty_generate(api.currencies)

end

if priv == true
			#puts api.get_info
			#puts api.get_info2
			##puts api.get_personal_info
			#puts api.active_orders(pair = '')
			#puts api.trade_history(pair)
			puts JSON.pretty_generate(api.trade_history('','','','','','','','',false))

			currency = 'btc'

			#puts api.withdraw(currency, amount, address, fee = nil, message = nil)

			#puts api.deposit_history(currency)
			#puts api.withdraw_history(currency)
end
