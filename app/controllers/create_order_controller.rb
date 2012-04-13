require './lib/openpayu.rb'
require './config.rb'

class CreateOrderController < ApplicationController
attr_accessor :docresp

  def index

  	@ipaddr = request.remote_ip

  	SpecialSession.id = OpenSSL::Digest.hexdigest("md5", rand().to_s).to_s
  	@myUrl = request.host.to_s + ":" + request.port.to_s + "/payu_step_by_step"
  	@clientIp = request.remote_ip
	

  	@shippingCost = Hash.new
  	@shippingCost = { 'CountryCode' => 'PL', 
                    	'ShipToOtherCountry' => 'true',
                    	'ShippingCostList' => {
                    	  'ShippingCost' => { 
                    	    'Type' => 'courier_0',
                          'CountryCode' => 'PL',
                          'Price' => { 'Gross' => '1220', 'Net' => '1000', 'Tax' => '22', 'TaxRate' => '22', 'CurrencyCode' => 'PLN'}
                          }
                        }
                      }                      

  	@item1 = Hash.new
  	@item1 = {  'Quantity' => 1,
                'Product' => {  
                  'Name' => 'name of test product',
                  'UnitPrice' => { 'Gross' => 10000, 'Net' => 7800, 'Tax' => 22, 'TaxRate' => '22', 'CurrencyCode' => 'PLN'}
                }
              }

  	#changed input
  	@shoppingCart = Hash.new
  	@shoppingCart = { 'GrandTotal' => 10000,
                      'CurrencyCode' => 'PLN',
                      'ShoppingCartItems' => {
                        'ShoppingCartItem' => [@item1]
                      }
                    }
                    
  	@order = Hash.new "Nonexistent key"
  	@order = {  'MerchantPosId' => OpenPayU::Configuration.merchantPosId,
              	'SessionId' => SpecialSession.id,
              	'OrderUrl' => "http://#{@myUrl}/layout/page_cancel?order=" + rand().to_s, # is url where customer will see in myaccount, and will be able to use to back to shop.
              	'OrderCreateDate' => Time.now.iso8601.to_s,
              	'OrderDescription' => OpenSSL::Digest.hexdigest("md5", rand().to_s).to_s,											
              	'MerchantAuthorizationKey' => OpenPayU::Configuration.posAuthKey ,
              	'OrderType' => 'MATERIAL', # keyword: MATERIAL or VIRTUAL 										
              	'ShoppingCart' => @shoppingCart
              }
  
  	@ocrq = {	'ReqId' =>  OpenSSL::Digest.hexdigest("md5", rand().to_s).to_s, 
                'CustomerIp' => @clientIp, # note, this should be real ip of customer retrieved from $_SERVER['REMOTE_ADDR']
                'NotifyUrl' => "http://#{@myUrl}/OrderNotifyRequest", #// url where payu service will send notification with order processing status changes
                'OrderCancelUrl' => "http://#{@myUrl}/layout/page_cancel",
                'OrderCompleteUrl' => "http://#{@myUrl}/layout/page_success",
                'Order' => @order,
                'ShippingCost' => {
                  'AvailableShippingCost' => @shippingCost,
                  'ShippingCostsUpdateUrl' => "#{@myUrl}/ShippingCostRetrieveRequest" #// this is url where payu checkout service will send shipping costs retrieve request 
                }															
              }
              
              
    @ocrs = OpenPayU::Order.create(@ocrq).response              
              
  end
end
