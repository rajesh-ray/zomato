class PartnerLocationUpdateWorker
	include Sidekiq::Worker
	def perform()
		partners = Partner.where("status in (?)", [0,1])
		partners.each do |partner|
			partner.assign_location
		end
	end
end