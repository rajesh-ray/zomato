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

		def update
	      	if params[:id]
	        	partner = Partner.find(params[:id]) rescue nil
	        	if partner.nil?
	          		render json: {status: 'FAILURE', 'message': 'Partner id does not exist'}, status: :bad_request and return
	       		else
	          		partner.name = (params['name']) ? params['name'] : partner.name
	          		partner.phone = (params['phone']) ? params['phone'] : partner.phone
	          		partner.status = (params['status']) ? params['status'] : partner.status
	          		byebug
	          		if params['location_lat'] and params['location_long']
	            		partner.location = set_coordinates_from_lat_long(params['location_lat'], params['location_long'])
	          		end
	          		# if params['coverage']
	            # 		partner.coverage = set_coordinates_from_poly_lat_long(params['coverage'])
	          		# end
	          		if partner.save
	            		render json: {status: 'SUCCESS', 'message': 'Partner updated', data: partner}, status: :ok
	          		else
	            		render json: {status: 'FAILURE', 'message': 'Partner not updated', data: task.errors}, status: :unprocessable_entity
	          		end
	        	end
	      	else
	        	render json: {status: 'FAILURE', 'message': 'Partner id param not specified'}, status: :bad_request and return
	      	end
    	end

		private

		def check_and_create_params
			required_params = ['name', 'phone', 'coverage']
			missing_params = required_params.select{|param| params[param].nil?}
			partner = params.slice(*required_params).as_json
			partner['coverage'] = set_coordinates_from_poly_lat_long(params['coverage'])
			partner = partner.slice('name', 'phone', 'coverage')
			return partner, missing_params 
		end

		def set_coordinates_from_poly_lat_long (poly)
	      	pol = poly.strip.split(" ")
	      	return nil if pol.size() < 3
	       	pol = pol.map{|x|
	           	FACTORY.point(x.split(',')[1].to_f.round(6), x.split(',')[0].to_f.round(6))
	        }
	        line = FACTORY.line_string(pol) rescue nil
	        boundary_polygon = FACTORY.polygon(line) rescue nil
    		return boundary_polygon
  		end

  		def set_coordinates_from_lat_long (lat, long)
		      latitude = lat.to_s.strip
		      longitude = long.to_s.strip
		      if /^(-)?[0-9]+(\.[0-9]+)?$/.match(latitude).nil? || /^(-)?[0-9]+(\.[0-9]+)?$/.match(longitude).nil?
		        coordinates = nil
		      else
		        coordinates = FACTORY.point(longitude.to_f.round(6), latitude.to_f.round(6))
		      end
		    return coordinates 
		end
	end
end