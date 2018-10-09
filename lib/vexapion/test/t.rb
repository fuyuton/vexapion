# coding: utf-8

require 'bigdecimal'
t1 = Time.now.to_f
sleep 1.1
t2 = Time.now.to_f
puts (BigDecimal(t2.to_s) - BigDecimal(t1.to_s)).to_f


base_time = Time.gm(2017, 9, 1, 0, 0, 0).to_i
@nonce = (Time.now.to_i*100 - base_time*100)  #max 100req/s

puts (BigDecimal(@nonce.to_s) / BigDecimal(100.to_s)).to_f

