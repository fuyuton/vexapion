require 'vexapion'

module Vexapion

	class HTTPClient
		
		attr_writer  :timeout, :timeout_keepalive, :min_interval, :num_of_retry

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

		def terminate
			@connections.values.each do |connection|
				connection.finish
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
			prev_wait = retry_wait = @sleep_in_sec
			@num_of_retry.times do
				#最低接続間隔の保証
				now = Time.now.to_f
				elapse = now - @last_access_time
				if elapse < @min_interval
					s = @min_interval - elapse
					sleep s
				end
				@last_access_time = Time.now.to_f
				#puts (@last_access_time - now + elapse).round(4)*1000
				
				begin
					#t1 = Time.now.to_f
					http = connection(uri, verify_mode)
					response = http.request(request)
					#t2 = Time.now.to_f
					#STDERR.puts "\nAPIcall: response: #{(t2-t1).round(4)*1000}ms"
				rescue SocketError => e
					fail SocketError.new(success, e.body, e)
					#raise
				end
				
				case response

				#1.success
				when Net::HTTPSuccess
					#2.success but response == nil
					if response.body == nil
						# puts warning message
						STDERR.puts Time.now.strftime("%d %H:%M:%S.%3N")
						str = "[HTTP error]\nurl=%s\nstatus=%d: %s\n"%[
							uri.to_s, response.code, response.message]
						STDERR.puts str
					end

					return response.body

				#3.server error
				when Net::ReadTimeout, Net::HTTPServerError
					# retryするつもりだったけど、アプリに任せる
					#retry_wait = wait_fb(prev_wait, retry_wait)
					handle_api_error(response)
					#raise

				#4.client error
				when Net::HTTPClientError
					# raise exception
					#print_error_message(uri, response.message)
					#raise Vexapion::HTTPClientException
					handle_api_error(response)
					#raise
				
				#5. other
				else
					fail Fatal.new(http_status_code, message)
					#raise
				end #of case

			end #of retry
			# error 
			raise VexapionServerError
		end #of response

		def wait_fb(prev_wait, retry_wait)
			sleep retry_wait
			retry_wait + prev_wait
		end

		def handle_api_error(response)
			http_status_code = response.code.to_i
			message = "#{response.message} #{response.body}"

			puts "http_status #{http_status_code}"

			case http_status_code
			when 400
				fail InvalidRequestError.new(http_status_code, message)

			when 401
				fail AuthenticationError.new(http_status_code, message)

			when 403
				fail ForbiddenError.new(http_status_code, message)

			when 404
				fail NotFoundError.new(http_status_code, message)

			when 408
				fail RequestTimeout.new(http_status_code, message)

			when 500
				fail ServiceUnavailableError.new(http_status_code, message)

			when 509
				fail LimitExceededError.new(http_status_code, message)

			else
				#puts "http_client.rb: Error: #{http_status_code} #{message}"
				fail Fatal.new(http_status_code, message)

			end #of case
		end #of handle_api_error

	end #of class

end #of module Vexapion
