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

#Class providing recognition of requests and responses.
#Used during building documents in OpenPayU.
#It's recommended not to create any object of this class
class Domain

	class << self
		attr_accessor :boundries
	end

	@boundries = {
		"OrderCreateRequest" 				=> "OrderDomainRequest",
		"OrderCreateResponse" 				=> "OrderDomainResponse",
		"OrderStatusUpdateRequest" 			=> "OrderDomainRequest",
		"OrderStatusUpdateResponse" 		=> "OrderDomainResponse",
		"OrderCancelRequest" 				=> "OrderDomainRequest",
		"OrderCancelResponse" 				=> "OrderDomainResponse",											
		"OrderNotifyRequest" 				=> "OrderDomainRequest",
		"OrderNotifyResponse" 				=> "OrderDomainResponse",											
		"OrderRetrieveRequest" 				=> "OrderDomainRequest",
		"OrderRetrieveResponse" 			=> "OrderDomainResponse",
		"ShippingCostRetrieveRequest" 		=> "OrderDomainRequest",
		"ShippingCostRetrieveResponse" 		=> "OrderDomainResponse"
	}

end #OpenPayU_Domain
end