require 'OpenSSL'
require 'net/http'
require 'net/https'
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

# Class providing communication between PayU and Client's service
# It's recommended not to create any object of this class.
class Network

	## Send data with authentication  
	## It's highly recommended not to directly call this method 
	##  IN: String, Hash, Hash
	##  OUT: String
	def self.sendDataAuth(doc, urlPath, headers) 
		payuService = Net::HTTP.new(OpenPayU::Configuration.serviceDomain, 443)
		payuService.use_ssl = true
		payuService.verify_mode = OpenSSL::SSL::VERIFY_NONE 
		response = payuService.post(urlPath, "#{doc}", headers)
		return response.body
	end

	## Method used to send data without any authentication  
	## It's highly recommended not to directly call this method 
	##  IN: String, Hash
	##  OUT: String
	def	self.sendData(doc, urlPath) 
		payuService = Net::HTTP.new(OpenPayU::Configuration.serviceDomain, 443)
		payuService.use_ssl = true
		payuService.verify_mode = OpenSSL::SSL::VERIFY_NONE 
		response = payuService.post(urlPath, "#{doc}")
		return response.body
	end
	
	## Method sending signed document
	##  IN: String, String, String, String, String
	##  OUT: String
	def self.sendOpenPayuDocumentAuth(doc, merchantPosId, signatureKey, urlPath, algorithm = "MD5")
		if algorithm == "MD5" then
			shortDoc = OpenSSL::Digest.hexdigest("md5", doc+signatureKey.to_s)
		elsif algorithm == "SHA1" then
			shortDoc = OpenSSL::Digest.hexdigest("sha1", doc+signatureKey.to_s)
		elsif algorithm == "SHA256" then
			shortDoc = OpenSSL::Digest.hexdigest("sha256", doc+signatureKey.to_s)
		end
		headers = {
			"OpenPayu-Signature: sender" => merchantPosId.to_s,
			"signature" => shortDoc,
			"algorithm" => algorithm,
			"content" => "DOCUMENT"
			}
		toSend = CGI::escape("#{doc}")
		return OpenPayU::Network.sendDataAuth("DOCUMENT="+toSend, urlPath, headers)
	end

	## Method used to send a document without signing it
	##  IN: String
	##  OUT: String
	def self.sendOpenPayuDocument(doc, urlPath)	
		toSend = CGI::escape("#{doc}")
		return OpenPayU::Network.sendData("DOCUMENT="+toSend, urlPath)			
	end
end #OpenPayU_Network
end