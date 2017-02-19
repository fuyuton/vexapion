# :stopdoc:
# coding: utf-8

require 'vexapion'
require 'bigdecimal'

module Vexapion

	class HTTPClient
		
		attr_writer :timeout, :timeout_keepalive, :min_interval
		attr_reader :response_time

		def initialize(i_sec=0.5, i_num=1)
			@connections = {}
			@timeout = 10
			#以前のリクエストで使ったコネクションの再利用を許可する秒数
			@timeout_keepalive = 300
			@sleep_in_sec  = i_sec
			@min_interval = i_sec
			@num_of_retry = i_num
			@last_access_time = Time.now.to_f
		end
		
		def disconnect
			@connections.values.each do |connection|
				connection.finish
			end
		end

		def terminate
			@connections.values.each do |connection|
				connection = nil
			end
		end

		def connection(uri, verify_mode)
			key = uri.host + uri.port.to_s + (uri.scheme == 'https').to_s
			if @connections[key].nil? || @connections[key].started?
				@connections[key] = build_http(uri, verify_mode)
			end
			@connections[key]
		end

		def build_http(uri, vmode)
			http = Net::HTTP.new(uri.host, uri.port, nil, nil)
			#http.set_debug_output($stderr)
			http.use_ssl = (uri.scheme == 'https')
			http.verify_mode = vmode #if (uri.scheme == 'https') && !vmode.nil?
			#p "set verify_mode #{vmode}" #if (uri.scheme == 'https') && !@vmode.nil?
			http.open_timeout = @timeout
			http.read_timeout = @timeout
			http.keep_alive_timeout = @timeout_keepalive

			http.start
			http
		end

		# HTTPのリクエスト
		# @param [String] uri  uri
		# @param [String] request request
		# @param [Integer] verify_mode OpenSSL::SSL::VERIFY_*を指定する
		# @raise SocketError  ソケットエラー
		# @raise RetryException リクエストが成功したか確認できない時 408, 500, 503
		# @raise Warning 何かおかしい時 (200&&response.body==nil), 509
		# @raise Error クライアントのエラー 400, 401, 403, 404
		# @raise Fatal APIラッパーの修正が必要になると思われるエラー
		# @return [String] request.bodyを返す
		def http_request(uri, request, verify_mode=nil)
			#最低接続間隔の保証
			now = Time.now.to_f
			elapse = f_minus(now, @last_access_time)
			if elapse < @min_interval
				s = f_minus(@min_interval, elapse)
				sleep s
			end
			@last_access_time = Time.now.to_f
			#puts (f_minus(@last_access_time, now) + elapse).round(4)*1000
			
			response = nil
			begin
				t1 = Time.now.to_f
				http = connection(uri, verify_mode)
				response = http.request(request)
				t2 = Time.now.to_f
				@response_time = f_minus(t2, t1).round(4)*1000
				#STDERR.puts "\nAPI response time: #{@response_time}ms"

			rescue SocketError, Net::OpenTimeout => e
				fail RetryException.new('0', e.body)

			rescue Net::ReadTimeout => e
				http_status_code = 408
				#message = "Timeout"
				fail RetryException.new(http_status_code, e.body)
			end
			
			handle_http_error(response) if response.code.to_i != 200

			return response.body
		end #of response

		def handle_http_error(response)
			http_status_code = response.code.to_i
			message = "#{response.message} #{response.body}"

			#2.server error
			case http_status_code
			when 500,502-504
				fail RetryException.new(http_status_code, message)

			#3.client error
			when 400,401,403,404
				fail Error.new(http_status_code, message)
			
			#4. other
			else
				#puts "http_client.rb: Error: #{http_status_code} #{message}"
				fail Fatal.new(http_status_code, message)

			end #of case
		end #of handle_api_error

		def f_minus(a, b)
			(BigDecimal(a.to_s) - BigDecimal(b.to_s)).to_f
		end

	end #of class

end #of module Vexapion
# :startdoc:

