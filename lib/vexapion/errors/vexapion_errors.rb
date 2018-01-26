# coding: utf-8

# @author @fuyuton fuyuton@pastelpink.sakura.ne.jp
module Vexapion

	class VexapionRuntimeError < StandardError
		attr_reader :code
		attr_reader :message

		# @api private
		def initialize(i_code, i_msg = nil)
			@code = i_code
			@message = i_msg
		end

		def to_s
			 "Server code:#{@code} message:#{@message}"
		end
	end

	#API level error
	class Warning < VexapionRuntimeError
	end

end #of Vexapion module

