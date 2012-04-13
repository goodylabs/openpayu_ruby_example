require 'OpenSSL'
require 'time'
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

# Class used to create and maintain the orders  
# It's recommended not to create any object of this class  
class Order

	## Method creating an order from an associative array.  
	## In situation when needed multiple values for one key, use 'key' => [value1,value2,...]
	##  IN: Hash
	##  OUT: OpenPayU::Result
	def self.create(order)
		OpenPayU::Configuration.environment()
		xml = OpenPayU.buildOrderCreateRequest(order)
		merchantPosId = OpenPayU::Configuration.merchantPosId
		signatureKey = OpenPayU::Configuration.signatureKey
		response = OpenPayU::Network.sendOpenPayuDocumentAuth(xml, merchantPosId, signatureKey, OpenPayU::Configuration.orderCreateReqPath)
		hashData = OpenPayU.makeMeHashTable(response, "XML")[1]
		status = OpenPayU.verifyResponse(hashData, "OrderCreateResponse")

		result=OpenPayU::Result.new
		result.status = status
		result.error = status["StatusCode"]
		result.request = xml
		result.response = response
		if (status["StatusCode"] == "OPENPAYU_SUCCESS") then 
			result.success = true
		else
			result.success = false
		end
		return result
	end

	## Method recognizing type of notification we get from PayU and passess it to appropriate method  
	## Remember to render 'response' attribute of returned object.
	##  IN: String (XML)
	##  OUT: OpenPayU::Result
	def self.consumeMessage(xml)
			hashData = OpenPayU.makeMeHashTable(xml, 'XML')
			hashData = hashData[1]
			msg = hashData['OpenPayU']['OrderDomainRequest']
		
			if msg['OrderNotifyRequest']!=nil then
					return OpenPayU::Order.consumeNotification(xml)
			elsif msg['ShippingCostRetrieveRequest']!=nil then
					return OpenPayU::Order.consumeShippingCostRetrieveRequest(hashData)
			else
					result = OpenPayU::Result.new
					result.message = xml
					return result
			end
	end

	## method building a response for PayU, returns OpenPayU_Result object.
	##  IN: String (XML)
	##  OUT: OpenPayU::Result
	def self.consumeNotification(xml)
			hashData = OpenPayU.makeMeHashTable(xml, 'XML')
			hashData = hashData[1]
			reqId = hashData['OpenPayU']['OrderDomainRequest']['OrderNotifyRequest']['ReqId']
			sessionId = hashData['OpenPayU']['OrderDomainRequest']['OrderNotifyRequest']['SessionId']
			rsp = OpenPayU.buildOrderNotifyResponse(reqId)
			result = OpenPayU::Result.new
			result.request = xml
			result.response = rsp
			result.success = 1	
			result.sessionId = sessionId
			result.message = 'OrderNotifyRequest'
			return result
		
	end

	## method prepares an OpenPayU_Result object to fill with shipping data on the POS side
	##  IN: Hash
	##  OUT: OpenPayU::Result
	def self.consumeShippingCostRetrieveRequest(hashData)
			result = OpenPayU::Result.new		
			result.countryCode = hashData['OpenPayU']['OrderDomainRequest']['ShippingCostRetrieveRequest']['CountryCode']
			result.reqId = hashData['OpenPayU']['OrderDomainRequest']['ShippingCostRetrieveRequest']['ReqId']
			result.message = 'ShippingCostRetrieveRequest'
			return result
	end

	## method used to updating order status on the PayU service side
	##  IN: String, Hash/String/Array
	##  OUT: OpenPayU::Result
	def self.updateStatus(sessionId, status)
			rq = { 	
				'ReqId' => OpenSSL::Digest.hexdigest("md5", rand().to_s).to_s,
				'MerchantPosId' => OpenPayU::Configuration.merchantPosId,
				'SessionId' => sessionId,
				'OrderStatus' => status,
				'Timestamp' => Time.now.iso8601.to_s
				}
			oauthResult = OpenPayU::OAuth.accessTokenByClientCredentials
			xml = OpenPayU.buildOrderStatusUpdateRequest(rq)
			response = OpenPayU::Network.sendOpenPayuDocumentAuth(xml, OpenPayU::Configuration.merchantPosId, OpenPayU::Configuration.signatureKey, OpenPayU::Configuration.orderStatusUpdPath + "?oauth_token=#{oauthResult.accessToken}")
			hashData = OpenPayU.makeMeHashTable(response, "XML")[1]
			status = OpenPayU.verifyResponse(hashData, 'OrderStatusUpdateResponse')
			result = OpenPayU::Result.new
			result.request = xml
			result.status = status
			result.error = status['StatusCode']
			if status['StatusCode'] == "OPENPAYU_SUCCESS" then
				result.success = true 
			else
				result.success = false
			end
			result.response = response	
			return result	
	end

	## method used to cancel an order
	##  IN: String
	##  OUT: OpenPayU::Result
	def self.cancel(sessionId) 
			rq = { 	
				'ReqId' => OpenSSL::Digest.hexdigest("md5", rand().to_s).to_s,
				'MerchantPosId' => OpenPayU::Configuration.merchantPosId,
				'SessionId' => sessionId
				}		
		
			url = "/" + OpenPayU::Configuration.country + "/standard/co/openpayu/OrderCancelRequest"		
			oauthResult = OpenPayU::OAuth.accessTokenByClientCredentials()
			xml = OpenPayU.buildOrderCancelRequest(rq)
			response = OpenPayU::Network.sendOpenPayuDocumentAuth(xml, OpenPayU::Configuration.merchantPosId, OpenPayU::Configuration.signatureKey, OpenPayU::Configuration.orderCancelReqPath + "?oauth_token=#{oauthResult.accessToken}")
			hashData = OpenPayU.makeMeHashTable(response, "XML")[1]
			status = OpenPayU.verifyResponse(hashData,'OrderCancelResponse')	
			result = OpenPayU::Result.new
			result.request = xml
			result.status = status
			result.error = status['StatusCode']
			if status['StatusCode'] == "OPENPAYU_SUCCESS" then
				result.success = true 
			else
				result.success = false
			end
			result.response = response
			return result
	end

	## method used to retrieve an order status from the PayU service
	##  IN: String
	##  OUT: OpenPayU::Result
	def self.retrieve(sessionId)	
			req = { 
				'ReqId' => OpenSSL::Digest.hexdigest("md5", rand().to_s).to_s,
				'MerchantPosId' => OpenPayU::Configuration.merchantPosId,
				'SessionId' => sessionId
				}
			url = "/" + OpenPayU::Configuration.country + "/standard/co/openpayu/OrderRetrieveRequest"
			oauthResult = OpenPayU::OAuth.accessTokenByClientCredentials()
			xml = OpenPayU.buildOrderRetrieveRequest(req)
			response = OpenPayU::Network.sendOpenPayuDocumentAuth(xml, OpenPayU::Configuration.merchantPosId, OpenPayU::Configuration.signatureKey, OpenPayU::Configuration.orderRetrieveReqPath + "?oauth_token=#{oauthResult.accessToken}")
			hashData = OpenPayU.makeMeHashTable(response,"XML")[1]
			status = OpenPayU.verifyResponse(hashData, 'OrderRetrieveResponse')
			result = OpenPayU::Result.new		
			result.status = status
			result.error = status['StatusCode']
			if status['StatusCode'] == "OPENPAYU_SUCCESS" then
				result.success = true 
			else
				result.success = false
			end 
			result.request = xml
			result.response = response
			return result
	end

end #Order
end