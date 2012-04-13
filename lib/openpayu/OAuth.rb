require 'cgi'
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

# Class providing getting access tokens from PayU
# It's recommended not to create any object of this class
class OAuth
	## Method returning access token to the user
	##  IN: String, String
	##  OUT: OpenPayU::ResultOAuth
	def self.accessTokenByCode(code, redirection)
		result = OpenPayU::ResultOAuth.new
		result.url = redirection
		result.code = code
		result.evalJson OpenPayU::OAuth.getAccessTokenByCode(code, redirection)
		return result
	end

	## Method prepares data to send to PayU and gets a token, which is further returned to accessTokenByCode
	##  IN: String, String
	##  OUT: String
	def self.getAccessTokenByCode(code, redirection)
		parameters = "code=#{code}&client_id=#{OpenPayU::Configuration.clientId}&client_secret=#{OpenPayU::Configuration.clientSecret}&grant_type=authorization_code&redirect_uri=#{redirection}"
		response = OpenPayU::Network.sendData(parameters, OpenPayU::Configuration.oAuthTokenByCodePath)
		return response
	end

	## Method returning access token to the user
	##  OUT: OpenPayU::ResultOAuth
	def self.accessTokenByClientCredentials 	
		result = OpenPayU::ResultOAuth.new
		result.url = OpenPayU::Configuration.serviceUrl + OpenPayU::Configuration.oAuthTokenByCCPath
		json = OpenPayU::OAuth.getAccessTokenByClientCredentials()
		json = CGI::unescapeHTML(json)
		json = CGI::unescape(json)
		result.evalJson(json)
		return result
	end

	## Method prepares data to send to PayU and gets a token, which is further returned to accessTokenByClientCredentials
	##  OUT: String
	def self.getAccessTokenByClientCredentials
		parameters = 'client_id=' + OpenPayU::Configuration.clientId + '&client_secret=' + OpenPayU::Configuration.clientSecret + '&grant_type=client_credentials'
		response = OpenPayU::Network.sendData(parameters, OpenPayU::Configuration.oAuthTokenByCCPath)	
		return response
	end 
end #OpenPayU_OAuth
end