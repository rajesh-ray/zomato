Rails.application.routes.draw do
	require 'sidekiq'
	require 'sidekiq-cron'
	require 'sidekiq/web'

	mount Sidekiq::Web => '/sidekiq'
	root 'welcome#index'
	namespace 'api' do
		resources :tasks do
			member do
				get 'index'
				post 'create'
				put 'update'
			end
		end
		resources :partners do
			member do
				get 'index'
				post 'create'
				put 'update'
			end
		end
		resources :maps
	end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
