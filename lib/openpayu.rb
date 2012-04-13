require 'openpayu/Domain'
require 'openpayu/Configuration'
require 'openpayu/Order'
require 'openpayu/Network'
require 'openpayu/OAuth'
require 'openpayu/ResultOAuth'
require 'openpayu/Result'


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

#Class providing document building utilities like converting between associative arrays and xml, as well as preparing requests such as OrderCancelRequest etc.
#class OpenPayU

	#Method used to convert associative array to XML string
	# IN: Hash, String(optional)
	# OUT: String (XML)
	def self.makeMeXML(hashtable, name = "")
		if name!="" then 
			xml = "<#{name}>" 
		else
			xml = ""
		end
		hashtable.each_pair do |key, value|
			if value.class == Hash then
				xml += makeMeXML(value, key)
			elsif value.class == Array
				value.each do |elem|
					xml += makeMeXML(elem, key)
				end
			else
				xml += "<#{key}>"
				xml += "#{value}"
				xml += "</#{key.split[0]}>"
			end
		end
		if name!="" then 
			xml += "</#{name.split[0]}>" 
		end
		return xml
	end

	 # Method used to convert XML string into an associative array  
	 # When pure XML passed, delete <?xml?> tag first using (mod="XML")
	 #  IN: String (xml), String
	 #  OUT: Array = [nil, Hash]
	def self.makeMeHashTable(str, mod ="")
		if mod == "XML" then
			str.gsub!(str.match(/<\?xml(.*?)\?>/m)[0],"")
		end
		hashData = Hash.new
		while not nil do
			openKey = str.match(/<([^?<>]*?)>/m)
			if openKey==nil then
				if hashData=={} then
					return [nil, str]
				else
					return [nil, hashData]
				end
			else
				openBracket = openKey[0]
				closBracket = openKey[0].split[0]
				if closBracket != openBracket then
					want=str.match(/#{openBracket}(.*?)<\/#{closBracket[1..-1]}>/m)
				else
					want=str.match(/#{openBracket}(.*?)<\/#{closBracket[1..-1]}/m)
				end
				elemToAdd = makeMeHashTable(want[1])
				if elemToAdd[0]==nil then
					str = str[want[0].length,str.length]
				end
				if hashData.has_key?(openKey[1].split[0]) then
					if hashData[openKey[1].split[0]].class==Array then
						hashData[openKey[1].split[0]] << elemToAdd[1]
					else
						hashData[openKey[1].split[0]]=[hashData[openKey[1].split[0]], elemToAdd[1]]
					end
				else
					hashData[openKey[1].split[0]] = elemToAdd[1]
				end
			end
		end
		return [nil, hashData]
	end

	# Method used to build XML document   
	#  IN: Hash, String, Bool (optional), String (optional), String (optional)  
	#  OUT: String (XML)  
	def self.buildOpenPayUDocument(hashData, startElem, isRequest = true, xml_version = '1.0', xml_encoding = 'UTF-8')
		headerHash = Hash.new
		headerHash = {
			'Algorithm' => 'MD5',				
			'SenderName' => 'exampleSenderName',
			'Version' => xml_version,
			}
		if isRequest then
			headerHash = {"HeaderRequest" => headerHash}
		else
			headerHash = {"HeaderResponse" => headerHash}
		end
		hashData = 	{OpenPayU::Domain.boundries[startElem] => {startElem => hashData}}
		data = {"OpenPayU xmlns=\"http://www.openpayu.com/openpayu.xsd\"" => headerHash.merge(hashData)}
		xml = "<?xml version=\"#{xml_version}\" encoding=\"#{xml_encoding}\" ?>" + OpenPayU.makeMeXML(data)
		return xml 
	end

	 # buildOrderRetrieveRequest  
	 #  IN: Hash  
	 #  OUT: String (XML)  
	def self.buildOrderRetrieveRequest(hashData)
		return OpenPayU.buildOpenPayUDocument(hashData, "OrderRetrieveRequest", true)
	end

	 # buildOrderCreateRequest  
	 #  IN: Hash  
	 #  OUT: String (XML)  
	def self.buildOrderCreateRequest(hashData)
		return OpenPayU.buildOpenPayUDocument(hashData, "OrderCreateRequest", true)
	end

	 # buildOrderCancelRequest  
	 #  IN: Hash  
	 #  OUT: String (XML)  
	def self.buildOrderCancelRequest(hashData) 
		return OpenPayU.buildOpenPayUDocument(hashData, "OrderCancelRequest", true)
	end

	 # buildOrderStatusUpdateRequest  
	 #  IN: Hash  
	 #  OUT: String (XML)  
	def self.buildOrderStatusUpdateRequest(hashData)
		return OpenPayU.buildOpenPayUDocument(hashData, "OrderStatusUpdateRequest", true)
	end

	 # buildShippingCostRetrieveResponse  
	 #  IN: Hash, String, String  
	 #  OUT: String (XML)  
	def self.buildShippingCostRetrieveResponse(hashData, reqId, countryCode)
		cost = {
			'ResId' =>  reqId, 
			'Status' => {'StatusCode' => 'OPENPAYU_SUCCESS'},
			'AvailableShippingCost' => hashData
		}
		return OpenPayU.buildOpenPayUDocument(cost, "ShippingCostRetrieveResponse", false)	
	end

	 # buildOrderNotifyResponse  
	 #  IN: String  
	 #  OUT: String (XML)  
	def self.buildOrderNotifyResponse(reqId)
		cost = {
			'ResId' =>  reqId, 
			'Status' => {'StatusCode' => 'OPENPAYU_SUCCESS'}
		}
		return OpenPayU.buildOpenPayUDocument(cost, "OrderNotifyResponse", false)	
	end

	 # verifyResponse  
	 # Method returning status from received data  
	 #  IN: Hash, String  
	 #  OUT: Hash  
	def self.verifyResponse(hashData, message)
		if hashData['OpenPayU']['OrderDomainResponse'][message]!= nil then
			status = hashData['OpenPayU']['OrderDomainResponse'][message]['Status']
		else
			status = hashData['OpenPayU']['HeaderResponse']['Status']
		end
		return status		
	end

#end #OpenPayU
end