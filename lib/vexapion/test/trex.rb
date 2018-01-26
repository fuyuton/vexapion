require 'json'
require 'yaml'
require 'vexapion/bittrex'

keyfile = "key/trex.yml"
file = File.read(keyfile)
key = YAML.load(file)

api = Vexapion::Bittrex.new(key['access-key'], key['secret-key'])
pair = 'BTC-LTC'

public = true
priv = false

if public
		puts 'api.getmarkets'
		puts JSON.pretty_generate(api.getmarkets)

		puts 'api.getcurrencies'
		puts JSON.pretty_generate(api.getcurrencies)

		puts 'api.getticker(market: pair)'
		puts JSON.pretty_generate(api.getticker(market: pair))

		puts 'api.getmarketsummaries'
		puts JSON.pretty_generate(api.getmarketsummaries)

		puts 'api.getmarketsummary(market: pair)'
		puts JSON.pretty_generate(api.getmarketsummary(market: pair))

		puts 'api.getorderbook(market: pair, type:\'both\')'
		puts JSON.pretty_generate(api.getorderbook(market: pair, type:'both'))

		puts 'api.getmarkethistory(market: pair)'
		puts JSON.pretty_generate(api.getmarkethistory(market: pair))
end

if priv
		puts api.buylimit(market: pair, quantity: 0.001, rate: buy_rate)
		puts api.selllimit(market: pair, quantity: 0.001, rate: sell_rate)
		#puts api.cancel(uuid:)

		puts api.getopenorders(market: pair)
		puts api.getbalances
		puts api.getbalance(currency: cur)

		puts api.getorder(uuid:'')
		puts api.getorders
		puts api.getorderhistory(market: '')

		puts api.getwithdrawalhistory(currency: '')
		puts api.getdeposithistory(currency: '')
		puts api.getdepositaddress(currency: cur)
		#puts api.withdraw(currency: , quantity:, address:, paymentid:'')
end
