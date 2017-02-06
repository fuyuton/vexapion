require 'net/http'
require 'openssl'
require 'uri'
require 'json'
require 'time'
require 'bigdecimal'

require 'vexapion/version'
require 'vexapion/errors/vexapion_errors'
require 'vexapion/errors/http_errors'
require 'vexapion/connect/http_client'
require 'vexapion/base_exchanges'

Net::HTTP.version_1_2
