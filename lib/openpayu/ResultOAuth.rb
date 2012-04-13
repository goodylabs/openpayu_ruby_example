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

# class used to store token and other data used to maintain it
class ResultOAuth 
	attr_accessor :url, :code, :accessToken, :payuUserEmail, :payuUserId, :expiresIn, :refreshToken, :success, :error
	def initialize
		@url = ''			#---String
		@code = ''			#---String
		@accessToken = ''	#---String
		@payuUserEmail = ''	#---String
		@payuUserId = ''	#---String
		@expiresIn = ''		#---FixNum
		@refreshToken = ''	#---String
		@success = false	#---Bool
		@error = ''			#---String
	end
	## method parsing json string and supplementing attributes with data
	##  IN: String
	def evalJson(str)
		str.gsub!("\": ","\" => ")
		begin
			str = eval str
		rescue SyntaxError
			print "unexpected data in json response"
		end

		if str["access_token"]!=nil then @accessToken=str["access_token"] end
		if str["payu_user_email"]!=nil then @payuUserEmail = str["payu_user_email"] end
		if str["payu_user_id"]!=nil then @payuUserId = str["payu_user_id"] end
		if str["refresh_token"]!=nil then @refreshToken = str["refresh_token"] end
		if str["expires_in"]!=nil then @expiresIn = str["expires_in"] end
		if str["error"]==nil then
			@success= true
		else
			@error=str["error_description"] if not str["error_description"].nil?
			@success=false
		end
	end

=begin
	## Method returning string representation of self. used for debugging purposes only
	##  OUT: String
	def prt
		str = ""
		self.instance_variables.each do |att|
			z = eval att.to_s
			str = str + att.to_s + ": " + z.to_s + "<br>
"
		end
		return str
	end
=end
end
end