require 'singleton'
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

# Class providing environment configuration. It's very important to call it's method OpenPayU::Configuration.environment to initialize some variables.
# It's recommended not to create any objects of this class, all its methods are class methods.
# Any method can be called in a way: OpenPayU::Configuration.methodName
class Configuration
	include Singleton
	#attributes accessors (class methods)
	class << self
		attr_accessor :env, :merchantPosId, :posAuthKey, :clientId, 
		:clientSecret, :signatureKey, :serviceUrl, :summaryUrl, :authUrl, :serviceDomain, :myUrl, :country, :oAuthTokenByCodePath, :oAuthTokenByCCPath, :orderCreateReqPath, :orderStatusUpdPath, :orderCancelReqPath, :orderRetrieveReqPath
	end
	#Those attributes must be supplemented with data from your PayU account
	@env = ''						# sandbox/secure
	@merchantPosId = ''				# POS id
	@posAuthKey = ''				# POS authentication key
	@clientId = ''					# client id
	@clientSecret = ''				# client secret
	@signatureKey = ''				# signature key
	@serviceUrl = ''
	@summaryUrl = ''
	@authUrl = ''
	@serviceDomain = ''
	@country = ''


	##environment - Method preparing the rest of configuration data
	## IN: String, String, String
	## OUT: Fixnum
	def self.environment(value = "sandbox", domain = 'payu.pl', country = 'pl')
		value = value.to_s.downcase
		domain = domain.to_s.downcase
		country = country.to_s.downcase		
		@country = country
		if (value == 'sandbox' || value == 'secure')
			@env = value
			@serviceDomain = value + "." + domain
			@serviceUrl = "https://" + value.to_s + '.' + domain.to_s	
			@summaryUrl = @serviceUrl + "/" + country + "/standard/co/summary"
			@authUrl = @serviceUrl +  "/" + country + "/standard/oauth/user/authorize"
			@oAuthTokenByCodePath	= "/" + country + "/standard/user/oauth/authorize"
			@oAuthTokenByCCPath		= "/" + country + "/standard/oauth/authorize"
			@orderCreateReqPath 	= "/" + country + "/standard/co/openpayu/OrderCreateRequest"				#create
			@orderStatusUpdPath 	= "/" + country + "/standard/co/openpayu/OrderStatusUpdateRequest"			#updateStatus
			@orderCancelReqPath 	= "/" + country + "/standard/co/openpayu/OrderCancelRequest" #cancel
			@orderRetrieveReqPath 	= "/" + country + "/standard/co/openpayu/OrderRetrieveRequest" #retrieve
			return 0 # correct environment type - all variables initialized
		end
		return 1 	# incorrect environment type
	end
end #OpenPayU_Configuration
end