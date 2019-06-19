Rails.application.routes.draw do
	root 'welcome#index'
	namespace 'api' do
		resources :tasks
		resources :partners
		post '/task' => "task#create"
		post '/partner' => "partner#create"
	end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
