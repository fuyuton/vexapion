# coding: utf-8

# @author @fuyuton fuyuton@pastelpink.sakura.ne.jp
module Vexapion

	class VexapionRuntimeError < StandardError
		attr_reader :code
		attr_reader :message
		attr_reader :body

		# @api private
		def initialize(i_code, i_msg = nil, i_body = nil)
			@code = i_code
			@message = i_msg
      @body = i_body
		end

		def to_s
			 @message
		end
	end

	#API level error
	class Warning < VexapionRuntimeError
	end

end #of Vexapion module

