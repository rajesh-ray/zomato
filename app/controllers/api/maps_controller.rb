module Api
	class MapsController < ApplicationController

  		def index
    		if params[:partner_id]
		    	partner = Partner.find(params[:partner_id])
		    	factory = RGeo::GeoJSON::EntityFactory.instance
		    	feature = factory.feature partner.coverage
		    	hash = RGeo::GeoJSON.encode feature
		    	byebug
		    	File.open('partner.json', 'w') {|file| file.write hash.to_json}
    		end
  		end
  	end
end