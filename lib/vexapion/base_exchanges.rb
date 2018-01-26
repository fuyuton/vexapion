# coding: utf-8

module Vexapion

	# Virtual (crypto) Currency Exchanges API wrapper class

	class BaseExchanges
		attr_reader	:response_time

		#@api private
		def initialize(key = nil, secret = nil)
			@key = key
			@secret = secret
			@conn = HTTPClient.new
			base_time = Time.gm(2017, 9, 1, 0, 0, 0).to_i
			@nonce = (Time.now.to_i*100 - base_time*100)  #max 100req/s
			@verify_mode = nil
			set_min_interval(0.5)
		end

		#@api private
		def get_nonce
			@nonce += 1
		end

		def disconnect
			begin 
				@conn.terminate
			rescue RetryException, Warning, Error => e
				puts "disconnect Warn: #{e}"
			end
		end

		def set_timeout(sec)
			@conn.timeout = sec
		end

		def set_min_interval(sec)
			@conn.min_interval = sec
		end

		def set_verify_mode(mode)
			@verify_mode = mode
		end

		def do_command(uri, request)
			response = @conn.http_request(uri, request, @verify_mode)
			@response_time = @conn.response_time

			response == '' ? '' : JSON.parse(response)
		end

	end #of class

end #of Vexapion module
