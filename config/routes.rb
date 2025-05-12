Rails.application.routes.draw do
  root "forecasts#new"

  post "/forecast", to: "forecasts#create"
end
