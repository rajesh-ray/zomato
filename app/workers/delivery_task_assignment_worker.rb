#app/workers/delivery_task_worker.rb

class DeliveryTaskAssignmentWorker
	include Sidekiq::Worker
	sidekiq_options retry: true

	def perform(task_id)
		task = Task.find(task_id)
		source = task.source
		destination = task.destination
		if task.status != 2
			source = source.as_text.scan(/[+-]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?/).collect{|s| s.to_f}
			lon1 = source[0]
			lat1 = source[1]
			destination = destination.as_text.scan(/[+-]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?/).collect{|s| s.to_f}
			lon2 = destination[0]
			lat2 = destination[1]

			sql = "SELECT id FROM partners WHERE ST_DWithin(coverage, ST_Point(#{task.source.coordinates.join(',')}), 0) AND ST_DWithin(coverage, ST_Point(#{task.destination.coordinates.join(',')}), 0)"
			partners_serveable = ActiveRecord::Base.connection.execute(sql)
			partner_ids = partners_serveable.as_json.map{|hsh|hsh["id"]}
		
			if partners_serveable.count != 0
				sql = "SELECT id, name, ST_Distance(location, ST_GeographyFromText('SRID=4326;POINT(#{lon1} #{lat1})')) AS distance FROM partners WHERE id IN (#{partner_ids.join(',')}) ORDER BY distance"
				records_array = ActiveRecord::Base.connection.execute(sql)
				if records_array.count > 0
					task.partner_id = records_array.first['id']
					task.status = 2
					task.save
				end
			else
				raise "partner not assigned for task_id #{task.id}"
			end
		end
	end

	private

	def distance_between(lat1, lon1, lat2, lon2)
      dlon = lon2 - lon1
      dlat = lat2 - lat1
      dlon_rad = dlon * RAD_PER_DEG
      dlat_rad = dlat * RAD_PER_DEG
      lat1_rad = lat1 * RAD_PER_DEG
      lon1_rad = lon1 * RAD_PER_DEG
      lat2_rad = lat2 * RAD_PER_DEG
      lon2_rad = lon2 * RAD_PER_DEG
      a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
      c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
      return (METERS_PER_UNIT_CHANGE * c).round(2)
    end
end
