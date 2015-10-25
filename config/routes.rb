# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :cost_entries,  :controller => 'cost_entry'  do
  get 'report', :on => :collection
end
resources :issues do
  resources :cost_entries,  :controller => 'cost_entry'  do
    get 'report', :on => :collection
  end
end
resources :projects do
  resources :cost_entries,  :controller => 'cost_entry'  do
    get 'report', :on => :collection
  end

  post 'project_cost/set_costs', controller: :project_cost, action: :set_costs
end