module Vexapion
	module API

		# Virtual Currency Exchanger API wrapper class
		class BaseExchanger

			def initialize(key = nil, secret = nil)
				@key = key
				@secret = secret
				@conn = HTTPClient.new
				base_time = Time.gm(2017, 1, 1, 0, 0, 0).to_i
				@nonce = (Time.now.to_i - base_time) * 100	#max 100req/s
				@verify_mode = nil
				set_min_interval(1)
			end

			def set_min_interval(sec)
				@conn.min_interval = sec
			end

			def set_verify_mode(mode)
				@verify_mode = mode
			end

			def do_command(uri, request)
				response = nil
				#p uri
				#p request
				begin
					response = @conn.http_request(uri, request, @verify_mode)
					#puts response
				rescue VexapionRuntimeError => e
					raise
				rescue HTTPError => e
					#handle_api_error(e.response)
					#raise e
					raise
				end
					
				response == nil ? nil : JSON.parse(response)
				#if response == nil
				#	return nil
				#end

				#JSON.parse(response)
			end
				
			def get_nonce
				@nonce += 1
			end

		end #of class
	end #of API module
end #of Vexapion module
