# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :records do
    resources :local_notes, param: :note_id
    resources :local_var_labels, param: :var_label_id
  end

  post "/marc_file/ids", to: "marc_file#ids"
  post "/marc_file/delete", to: "marc_file#delete"

  mount Rswag::Ui::Engine => '/'
  mount Rswag::Api::Engine => '/api-docs'
end
