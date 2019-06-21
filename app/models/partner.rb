class Partner < ApplicationRecord
	def assign_location
		if( self.status == 0 || self.location.nil?) 
			self.location = get_coverage_centroid(self.id)
			self.status = 1
		else
		 	self.location = move_randomly(self.id, self.location, self.coverage)
		end
		self.save
	end

	def get_coverage_centroid(id)
		query = "SELECT ST_Centroid((SELECT coverage FROM partners WHERE id = #{id})) AS centroid"
		record = ActiveRecord::Base.connection.execute(query)
		return record.first['centroid']
	end

	def move_randomly(id, location, coverage)
		explore_limit = 10

		while explore_limit
			moveable, transformed_point = get_transformed_point(id, location, coverage)
			if moveable
				return transformed_point
			end
			explore_limit -= 1
		end

		return self.location
	end

	def get_transformed_point(id, location, coverage)
		possible_azimuth = [0.0, 90.0, 180.0, 270.0]
		direction = possible_azimuth.sample(1)[0]
		query = "SELECT ST_AsText(ST_Project('#{location}'::geography, 500, radians(#{direction}))) AS transformed_point"
		record = ActiveRecord::Base.connection.execute(query)
		point = record.first['transformed_point'].scan(/[+-]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?/).collect{|s| s.to_f.round(6)}
		sql = "SELECT ST_DWithin(coverage, ST_Point(#{point[0]}, #{point[1]}), 0) AS moveable FROM partners WHERE id=#{id}"
		result = ActiveRecord::Base.connection.execute(sql)
		return [result.first['moveable'], record.first['transformed_point']]
	end
end
