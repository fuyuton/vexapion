module Vexapion
	module API

		# Virtual (crypto) Currency Exchanges API wrapper class

		class BaseExchanges

			def initialize(key = nil, secret = nil)
				@key = key
				@secret = secret
				@conn = HTTPClient.new
				base_time = Time.gm(2017, 1, 1, 0, 0, 0).to_i
				@nonce = (Time.now.to_i - base_time) * 100	#max 100req/s
				@verify_mode = nil
				set_min_interval(0.5)
			end

			def set_min_interval(sec)
				@conn.min_interval = sec
			end

			def set_verify_mode(mode)
				@verify_mode = mode
			end

			def do_command(uri, request)
				response = nil
				begin
					response = @conn.http_request(uri, request, @verify_mode)
				rescue VexapionRuntimeError => e
					raise e
				rescue HTTPError => e
					raise e
				end
					
				response == nil ? nil : JSON.parse(response)
			end
				
			def get_nonce
				@nonce += 1
			end

			def error_check(res)
				if res.has_key?('error')
					#通信は成功した。だがリクエストは失敗した"
					fail RequestFailed.new(
						false, res['error'], res)
				end
			end

		end #of class

	end #of API module
end #of Vexapion module
