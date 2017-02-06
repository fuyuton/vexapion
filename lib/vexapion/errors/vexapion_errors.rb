# based off of quandl gem: https://github.com/quandl/quandl-ruby
#
#	vexapion_exception.rb
#
# since 2017/1/20
# ver 1.0
#
# written by @fuyuton
#


module Vexapion
	module API

		class VexapionRuntimeError < StandardError
			attr_reader :success
			attr_reader :error_message
			attr_reader :response

			def initialize(i_success = nil, i_msg = nil, i_response = nil)
				@success = i_success
				@message = i_msg
				@response = i_response
			end

			 def to_s
				 "#{@error_message}: #{@response}"
			 end
		end

		#Error Response
		class RequestFailed < VexapionRuntimeError
		end

		#Socket Error
		class SocketError < VexapionRuntimeError
		end

	end #of API module
end #of Vexapion module
