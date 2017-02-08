require 'vexapion/bitflyer'
require 'yaml'

pair1 = 'BTC_JPY'
pair2 = 'BTC_JPY'

home_dir = "/home/fuyuton"
key_file = "#{home_dir}/.key/test/bf.yml"
file = File.read(key_file)
key = YAML.load(file)

api = Vexapion::Bitflyer.new(key['access-key'], key['secret-key'])
#api = Vexapion::Bitflyer.new


res = api.ticker(pair1)
ask = res['best_ask']
bid = res['best_bid']


			puts "api.get_positions"
			puts api.get_positions('FX_BTC_JPY')


	puts "\n\nEnd of #{__FILE__} test\n\n"
