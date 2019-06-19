Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0'  }
  schedule_file = "config/schedule.yml"
  if File.exists?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

class PartnerLocationUpdateWorker
  include Sidekiq::Worker
  def perform()
    partners = Partner.where("status in (?) and location is null", [0,1])
    byebug
    partners.each do |partner|
    	partner.assign_location
    end
  end
end


Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0'  }
end