Rails.application.routes.draw do



  get 'connect', to: 'connect#index'
	# get '/cron_job', to: 'cron#cron_job'

	resources :jails, only: [:index, :show]
	resources :updates, only: [:index, :show]
	resources :notices, only: [:index, :show]
	resources :seelog, only: [:index]
	resources :console, only: [:index]
	resources :reports

	match "/combatlog" => "combatlog#update", :via => :get
	match "/messagelog" => "messagelog#update", :via => :get

	mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

	devise_for :users, controllers: {
	sessions: 'users/sessions'
	}
	root 'home#index'



# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end