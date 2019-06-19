#app/workers/delivery_task_worker.rb

class DeliveryTaskAssignmentWorker
	include Sidekiq::Worker
	sidekiq_options retry: false

	def perform(task_id)
		task = Task.find(task_id)
		byebug
	end
end
