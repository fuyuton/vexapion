# coding: utf-8

module Vexapion

	# Virtual (crypto) Currency Exchanges API wrapper class

	class BaseExchanges

		def initialize(key = nil, secret = nil)
			@key = key
			@secret = secret
			@conn = HTTPClient.new
			base_time = Time.gm(2017, 1, 1, 0, 0, 0).to_i
			@nonce = (Time.now.to_i - base_time) * 100  #max 100req/s
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

			response == '' ? '' : JSON.parse(response)
		end
			
		def get_nonce
			@nonce += 1
		end

		def error_check(res)
			if res != nil && res != '' && res.kind_of?(Hash)
				
				if res['success'] == 0 || res['success'] == 'false'
				  #polo
					fail RequestFailed.new(
						false, false, res)
				elsif res.has_key?('error')
				  #zaif, polo
					fail RequestFailed.new(
						false, res['error'], res)
				elsif res.has_key?('error_message') 
				  #bitflyer
					fail RequestFailed.new(
						false, "#{res['status']} #{res['error_message']}", res)
				end
			end

		end

	end #of class

end #of Vexapion module
