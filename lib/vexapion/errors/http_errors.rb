# :stopdoc:
# coding: utf-8

# based off of quandl gem: https://github.com/quandl/quandl-ruby

module Vexapion

	class HTTPError < StandardError
		attr_reader :http_status_code
		attr_reader :message

		def initialize(code = nil, msg = nil)
			@http_status_code = code
			@message = msg
		end

		 def to_s
			 "#{@http_status_code}: #{@message}"
		 end
	end

	#apiラッパー側でリトライさせたいエラー
	class RetryException < HTTPError
	end

	#アプリ側で止めて書き直しが必要なエラー
	class Error < HTTPError
	end

	#ラッパーの書き直しが必要なエラー
	class Fatal < HTTPError
	end

end #of Vexapion module
# :startdoc:

