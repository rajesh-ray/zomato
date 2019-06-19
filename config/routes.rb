Rails.application.routes.draw do
	require 'sidekiq'
	require 'sidekiq-cron'
	require 'sidekiq/web'

	mount Sidekiq::Web => '/sidekiq'
	root 'welcome#index'
	namespace 'api' do
		resources :tasks
		resources :partners
		resources :maps
		post '/task' => "task#create"
		post '/partner' => "partner#create"
	end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
