require 'vexapion/bitstamp'
require 'yaml'
require 'bigdecimal'
require 'json'


def fminus(a, b)
  (BigDecimal(b.to_s) - BigDecimal(a.to_s)).to_f
end


pair = 'ethbtc'

key_file = 'key/stamp.yml'
file = File.read(key_file)
key = YAML.load(file)

api = Vexapion::Bitstamp.new(key['access-key'], key['secret-key'], key['customer_id'])

public = true
private = false
trade = false
withdraw = false



if public
    puts 'ticker'
    t1 = Time.now.to_f
		#puts api.ticker(pair:pair)
    t2 = Time.now.to_f
    #puts "#{fminus(t1, t2)}sec"
    #puts 'ticker_hour'
		#puts api.ticker_hour(pair:pair)
    #puts 'order_book'
		#puts api.order_book(pair:pair)
    #puts 'transactions'
		#puts api.transactions(pair:pair, time:nil)
    puts 'trading_pairs_info'
		puts api.trading_pairs_info
    #puts 'eur_usd'
		#puts api.eur_usd
end

if private
		puts 'account_balance'
		puts api.account_balance
		puts 'user_transactions'
		puts api.user_transactions(pair:pair, offset: 0, limit: 100, sort: "desc")
		puts 'open_orders'
		puts api.open_orders(pair: pair)
end


# 1 order > $5
if trade
		puts api.ticker(pair:pair)
    price = 0.1
    amount = 0.1

		#puts res = api.buy_limit_order(pair: pair, price:, amount:, limit_price: nil, daily_order: false, ioc_order: false)
		#puts res = api.buy_limit_order(pair:, amount:)
		#puts res = api.sell_limit_order(pair:pair, price:price, amount:amount, limit_price: nil, daily_order: false, ioc_order: false)
		res = api.sell_limit_order(pair:pair, price:price, amount:amount)
    puts JSON.pretty_generate(res)
    id = res['id']
    puts "id=#{id}"
		#puts res = api.sell_limit_order(pair:, amount:)
		#puts 'order_status'
		#puts api.order_status(id: id)
    puts 'open_orders'
		puts api.open_orders(pair: pair)
    #id = 1831722469
    puts 'cancel'
		puts res = api.cancel_order(id:id)
		#puts res = api.cancel_all_orders
end

if withdraw
		puts res = api.withdrawal_requests(timedelta: nil)
		#puts res = api.bitcoin_withdrawal(amount:, address:, instant:0)
		#puts res = api.altcoin_withdrawal(currency:, amount:, address:)
		#puts res = api.altcoin_deposit_address(currency: )
		puts res = api.unconfirmed_btc
		#puts res = api.transfer_to_main(currency:, amount:, sub_account:nil)
		#puts res = api.transfer_from_main(currency:, amount:, sub_account:nil)
		##puts res = api.bank_withdrawal( amount:, currency:, name:, iban:, bic:, address:, postal_code:, city:, country:, type:,
		#puts res = api.bank_withdrawal_status(id: )
		#puts res = api.cancel_bank_withdrawal(id: )
		#puts res = api.create_liquidation_address(currency:)
		#puts res = api.liquidation_address_info(address: nil)
end

