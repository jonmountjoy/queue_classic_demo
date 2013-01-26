QueueClassicDemo::Application.routes.draw do

  # Called to display the main job-submission form UI
  get "front/new"

  # Called by the form to poll for job completion
  get 'front/fetch/:counter' => 'front#fetch', :as => :fetch

  # Called to submit a new job from the form
  match '/front/create(/:email)' => 'front#create' , :as => :go

  root :to => 'front#new'

end
