module OpenPayU
=begin
	ver 0.1.0
	
	OpenPayU Standard Library
	@copyright  Copyright (c) 2012 PayU
	@license    http://opensource.org/licenses/LGPL-3.0  Open Software License (LGPL 3.0)
	http://www.payu.com
	http://twitter.com/openpayu

	
	
	CHANGE_LOG: 
		2012-02-18, ver. 0.1.0
		- start file
=end

# Class representing process of communication between client service and PayU
# used to store the request, response, and some other very useful data.
class Result
		attr_accessor :status, :error, :success, :request, :response, :sessionId, :message, :countryCode, :reqId
	def initialize 
		@status = ''		#---Hash
		@error = ''			#---String
		@success = false	#---Bool
		@request = ''		#---String (XML)
		@response = ''		#---String (XML)
		@sessionId = ''		#---String
		@message = ''		#---String
		@countryCode = ''	#---String
		@reqId = ''			#---String
	end
end #OpenPayU::Result
end