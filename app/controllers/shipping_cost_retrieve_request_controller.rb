require './lib/openpayu.rb'
require './config.rb'

class ShippingCostRetrieveRequestController < ApplicationController

	def index
		@xml = params['DOCUMENT']
		@xml = CGI::unescapeHTML(@xml)	

		fil = File.open("Shipping.txt","a")
		fil.puts("#{Time.now}\t" +@xml)
		fil.close

		result = OpenPayU::Order.consumeMessage(@xml)			 
		if (result.message == 'ShippingCostRetrieveRequest') then

			arr = { 'CountryCode' => result.countryCode, 
              'ShipToOtherCountry' => 'true',
              'ShippingCostList' => {
                'ShippingCost' => [{
                  'Type' => 'recalculated_courier_0',
                  'CountryCode' => result.countryCode,
                  'Price' => {'Gross' => '1220', 'Net' => 220, 'Tax' => '22', "TaxRate" => 22, "CurrencyCode" => "PLN"}
                  },
                  {
                    'Type' => 'recalculated_courier_1',
                    'CountryCode' => result.countryCode,
                    'Price' => {'Gross' => '2440', 'Net' => 440, 'Tax' => '22', "TaxRate" => 22, "CurrencyCode" => "PLN"}
                  }]
                }
              }
		end
		
		@xml = OpenPayU.buildShippingCostRetrieveResponse(arr, result.reqId, result.countryCode)
		render :text => @xml
	end
	
end
