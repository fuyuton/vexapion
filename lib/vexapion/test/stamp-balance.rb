require 'json'

def pair_symbol_convert(pair)
  pa = pair.downcase
  pa.gsub!(/usd|btc|eur/, "usd" => "_usd", "btc" => "_btc", "eur" => "_eur")
  #先頭に_がある場合、消す
  pa.gsub!(/^_/, "_" => "")
  pa
end

account_balance = {"bch_available"=>"0.00000000", "bch_balance"=>"0.00000000", "bch_reserved"=>"0.00000000", "bchbtc_fee"=>"0.25", "bcheur_fee"=>"0.25", "bchusd_fee"=>"0.25", "btc_available"=>"0.00000000", "btc_balance"=>"0.00000000", "btc_reserved"=>"0.00000000", "btceur_fee"=>"0.25", "btcusd_fee"=>"0.25", "eth_available"=>"1.00000000", "eth_balance"=>"1.00000000", "eth_reserved"=>"0.00000000", "ethbtc_fee"=>"0.25", "etheur_fee"=>"0.25", "ethusd_fee"=>"0.25", "eur_available"=>"0.00", "eur_balance"=>"0.00", "eur_reserved"=>"0.00", "eurusd_fee"=>"0.25", "ltc_available"=>"0.00000000", "ltc_balance"=>"0.00000000", "ltc_reserved"=>"0.00000000", "ltcbtc_fee"=>"0.25", "ltceur_fee"=>"0.25", "ltcusd_fee"=>"0.25", "usd_available"=>"0.00", "usd_balance"=>"0.00", "usd_reserved"=>"0.00", "xrp_available"=>"0.00000000", "xrp_balance"=>"0.00000000", "xrp_reserved"=>"0.00000000", "xrpbtc_fee"=>"0.25", "xrpeur_fee"=>"0.25", "xrpusd_fee"=>"0.25"}

account_balance.each do |k, v|
  if k =~ /_fee/
    key = k.gsub(/_fee/, "")
    key = pair_symbol_convert(key)
    puts "#{key}: #{v}" 
  end
end



