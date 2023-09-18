# Route for the BookAdmin engine
Rails.application.routes.draw do
  get '/books/:id' => 'books#show'
end
