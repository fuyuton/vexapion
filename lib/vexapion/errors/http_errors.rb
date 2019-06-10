# coding: utf-8

# based off of quandl gem: https://github.com/quandl/quandl-ruby

# @author @fuyuton fuyuton@pastelpink.sakura.ne.jp
module Vexapion

	class HTTPError < StandardError
		attr_reader :http_status_code, :code
		attr_reader :message, :body

		# @api private
		def initialize(code = nil, msg = nil, body = nil)
			@http_status_code = code
			@code = code
			@message = msg
      @body = body
		end

		 def to_s
			 "#{@http_status_code} / #{@message} / #{@body}"
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

