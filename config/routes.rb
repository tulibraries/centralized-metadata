Rails.application.routes.draw do
  resources :records do
    resources :local_notes, param: :note_id
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  mount Rswag::Ui::Engine => '/'
  mount Rswag::Api::Engine => '/api-docs'
end
