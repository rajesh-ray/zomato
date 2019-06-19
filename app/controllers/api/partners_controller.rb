module Api
	class PartnersController < ApplicationController
		skip_before_action :verify_authenticity_token
		def index
			if params[:partner_id]
				partner = Partner.find(params[:partner_id]) rescue nil
				if partner.nil?
					render json: {status: 'FAILURE', 'message': 'Partner id does not exist'}, status: :bad_request and return
				end
			else
				partner = Partner.order('created_at DESC')
			end
			render json: {status: 'SUCCESS', 'message': 'Fetched delivery boys', data: partner}, status: :ok
		end

		def create
			partner_params, missing_params = check_and_create_params
			byebug
			partner = Partner.new(partner_params.with_indifferent_access)
			partner.save
		end

		private

		def check_and_create_params
			required_params = ['name', 'phone', 'coverage']
			missing_params = required_params.collect{|param| params[params].nil?}
			partner = params.slice(*required_params).as_json
			partner['coverage'] = set_coordinates_from_lat_long(params['coverage'])
			partner = partner.slice('name', 'phone', 'coverage')
			return partner, missing_params 
		end

		def set_coordinates_from_lat_long (poly)
	      	polygon = poly.strip
	      	if /^([0-9]+(\.[0-9]+)?,[0-9]+(\.[0-9]+)?\s)+[0-9]+(\.[0-9]+)?,[0-9]+(\.[0-9]+)?$/.match(polygon).nil?
	        	boundary_polygon = nil
	      	else
	        	polygon = polygon.split(" ")
	        	polygon = polygon.map{|x|
	          		FACTORY.point(x.split(',')[0].to_f.round(6), x.split(',')[1].to_f.round(6))
	        	}
	        	boundary_polygon = FACTORY.polygon(FACTORY.linear_ring(polygon))
	        	boundary_polygon = FACTORY.project(boundary_polygon)
	      	end
    		return boundary_polygon
  		end
	end
end