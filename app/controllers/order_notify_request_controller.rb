require './lib/openpayu.rb'
require './config.rb'
class OrderNotifyRequestController < ApplicationController

	def index
		@doc = params['DOCUMENT']
		@doc = CGI::unescapeHTML(@x)
		
		fil = File.open("Notify.txt","a")
		fil.puts("#{Time.now}\t" +@doc)
		fil.close
		
		render :text => OpenPayU::Order.consumeMessage(@doc).response
	end
end
