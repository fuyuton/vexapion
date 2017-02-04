# based off of quandl gem: https://github.com/quandl/quandl-ruby
#
# http_errors.rb
#
# since 2017/1/1
# ver 1.1	階層化
#
# written by @fuyuton
#


module Vexapion
	module API
		class HTTPError < StandardError
			attr_reader :http_status_code
			attr_reader :message

			# rubocop:disable Metrics/ParameterLists
			def initialize(code = nil, msg = nil)
				@http_status_code = code
				@message = msg
			end
			# rubocop:enable Metrics/ParameterLists

			 def to_s
				 "#{@http_status_code}: #{@message}"
			 end
		end

		#apiラッパー側でリトライさせたいエラー
		class RetryException < HTTPError
		end

		#場合によってはアプリ側で無視できるエラー
		class Warning < HTTPError
		end

		#アプリ側で止めて書き直しが必要なエラー
		class Error < HTTPError
		end

		#ラッパーの書き直しが必要なエラー
		class Fatal < HTTPError
		end


		#500
		class InternalServerError < RetryException
		end

		#503
		class ServiceUnavailableError < RetryException
		end

		#Request Success but response.body == nil
		class ResponseDataError < Warning
		end

		#509, and API Limit?
		class LimitExceededError < Warning
		end

		#400
		class InvalidRequestError < Error
		end

		#401
		class AuthenticationError < Error
		end

		#403
		class ForbiddenError < Error
		end

		#404
		class NotFoundError < Error
		end

	end #of API module
end #of Vexapion module
