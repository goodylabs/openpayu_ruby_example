require './lib/openpayu.rb'
require './config.rb'
class CancelRequestController < ApplicationController
	def index
		OpenPayU::Configuration.environment
		@sessionId = params['sessionId']
		@status = params['status']
		@resp=""
		@req =""
		if (@sessionId != nil and @status != nil )then
			@result = OpenPayU::Order.retrieve(@sessionId)
		end
		if @result != nil then 
			@resp = @result.response 
		end
		if @result != nil then 
			@req = @result.request 
		end
	end
end
