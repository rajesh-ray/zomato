module Api
	class TasksController < ApplicationController
		skip_before_action :verify_authenticity_token
		def index
			if params[:task_id]
				task = Task.find(params[:task_id]) rescue nil
				if task.nil?
					render json: {status: 'FAILURE', 'message': 'Task id does not exist'}, status: :bad_request and return
				end
			else
				task = Task.order('created_at DESC')
			end

			render json: {status: 'SUCCESS', 'message': 'Fetched delivery tasks', data: task}, status: :ok
		end

		def create
			task_params, missing_params = check_and_create_params
			byebug
			if missing_params.include? true
			 	render json: {status: 'FAILURE', 'message': 'Please provide required params'}, status: :bad_request and return
			end
			
			task = Task.new(task_params.with_indifferent_access)
			
			if task.save
				byebug
				DeliveryTaskAssignmentWorker.perform_async(task.id)
				byebug
				render json: {status: 'SUCCESS', 'message': 'Task created', data: task}, status: :ok
			else
				render json: {status: 'FAILURE', 'message': 'Task not created', data: task.errors}, status: :unprocessable_entity
			end
		end

		private

		def check_and_create_params
			required_params = ['source_lat', 'source_long', 'destination_lat', 'destination_long']
			missing_params = required_params.collect{|param| params[param].nil?}
			task = params.slice(*required_params).as_json
			task['source'] = set_coordinates_from_lat_long(params['source_lat'], params['source_long'])
			task['destination'] = set_coordinates_from_lat_long(params['destination_lat'], params['destination_long'])
			task = task.slice('source', 'destination')
			return task, missing_params 
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