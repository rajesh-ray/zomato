class Partner < ApplicationRecord
	def assign_location
		if( self.status == 0 || self.location.nil?) 
			self.location = get_coverage_centroid(self.coverage)
		# else
		# 	self.location = move_randomly(self.location, self.coverrage)
		end
		self.save
	end

	def self.get_coverage_centroid(coverage)
		query = "SELECT ST_Centroid(coverage) AS centroid"
		record = ActiveRecord::Base.connection.execute(query)
		return record.first['centroid']
	end

	# def self.move_randomly(current, coverage)
	# 	return future_point
	# end
end
