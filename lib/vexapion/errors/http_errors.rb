# based off of quandl gem: https://github.com/quandl/quandl-ruby

module Vexapion
  module API

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

    #場合によってはアプリ側で無視できるエラー
    class Warning < HTTPError
    end

    #アプリ側で止めて書き直しが必要なエラー
    class Error < HTTPError
    end

    #ラッパーの書き直しが必要なエラー
    class Fatal < HTTPError
    end


    #408 Request Timeout
    class RequestTimeout < RetryException
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
    class NotFoundError < Fatal
    end

  end #of API module
end #of Vexapion module
