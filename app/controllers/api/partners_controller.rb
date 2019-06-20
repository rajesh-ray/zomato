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
			if missing_params.present? || partner_params['coverage'].nil?
				render json: {status: 'FAILURE', 'message': 'Please provide required valid params'}, status: :bad_request and return
			end

			partner = Partner.new(partner_params.with_indifferent_access)
			
			if partner.save
				render json: {status: 'SUCCESS', 'message': 'Partner created', data: partner}, status: :ok
			else
				render json: {status: 'FAILURE', 'message': 'Partner not created', data: partner.errors}, status: :unprocessable_entity
			end
		end

		private

		def check_and_create_params
			required_params = ['name', 'phone', 'coverage']
			missing_params = required_params.collect{|param| params[param].nil?}
			partner = params.slice(*required_params).as_json
			partner['coverage'] = set_coordinates_from_lat_long(params['coverage'])
			partner = partner.slice('name', 'phone', 'coverage')
			return partner, missing_params 
		end

		def set_coordinates_from_lat_long (poly)
	      	pol = poly.strip.split(" ")
	      	return nil if pol.size() < 3
	       	pol = pol.map{|x|
	           	FACTORY.point(x.split(',')[1].to_f.round(6), x.split(',')[0].to_f.round(6))
	        }
	        line = FACTORY.line_string(pol) rescue nil
	        boundary_polygon = FACTORY.polygon(line) rescue nil
    		return boundary_polygon
  		end
	end
end