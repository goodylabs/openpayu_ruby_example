require './lib/openpayu.rb'
require './config.rb'

class BeforeSummaryPageController < ApplicationController
	def index
		@code = params['code']
		@redirection = OpenPayU::Configuration.myUrl+ "/BeforeSummaryPage"
		@accessToken = OpenPayU::OAuth.accessTokenByCode(@code, @redirection)
	end
end
