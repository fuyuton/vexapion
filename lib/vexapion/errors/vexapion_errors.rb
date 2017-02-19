# :stopdoc:
# coding: utf-8

# based off of quandl gem: https://github.com/quandl/quandl-ruby

module Vexapion

	class VexapionRuntimeError < StandardError
		attr_reader :code
		attr_reader :message

		def initialize(i_code, i_msg = nil)
			@code = i_code
			@message = i_msg
		end

		 def to_s
			 @message
		 end
	end

	#API level error
	class Warning < VexapionRuntimeError
	end

end #of Vexapion module
# :startdoc:

