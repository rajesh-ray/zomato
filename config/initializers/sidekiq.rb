schedule_file = "config/schedule.yml"

class HardWorker
  include Sidekiq::Worker
  def perform(name, count)
    # do something
  end
end


if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end