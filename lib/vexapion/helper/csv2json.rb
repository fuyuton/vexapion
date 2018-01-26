require 'csv'
require 'json'

msg = Hash.new
file_name = "bitbankcc_errmsg.csv"
CSV.foreach(file_name) do |row|
	code = row[0]
	message = row[1]
	msg.merge!({code => message})

end

puts JSON.pretty_generate(msg)

