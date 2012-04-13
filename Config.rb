
	#Those attributes must be supplemented with data from your PayU account
	OpenPayU::Configuration.env = 'sandbox'
	OpenPayU::Configuration.merchantPosId = '37857'
	OpenPayU::Configuration.posAuthKey = 'ArJmhmF'
	OpenPayU::Configuration.clientId = '37857'
	OpenPayU::Configuration.clientSecret = '64dec4280702424aeea05ae85d20e15e'
	OpenPayU::Configuration.signatureKey = 'a8e58d7c77722ceb73fa3fe43bf9cd53'
	#For some special
	OpenPayU::Configuration.myUrl = 'http://localhost:3000/payu_step_by_step'
	
	OpenPayU::Configuration.serviceUrl = ''
	OpenPayU::Configuration.summaryUrl = ''
	OpenPayU::Configuration.authUrl = ''
	OpenPayU::Configuration.serviceDomain = ''
	OpenPayU::Configuration.country = ''

	OpenPayU::Configuration.environment


#Special Class only for demo. Holding and reseting session id (real shops will have their own session systems)

class SpecialSession
	class << self
		attr_accessor :id
	end
	@id = ''
end