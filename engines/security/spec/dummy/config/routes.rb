Rails.application.routes.draw do
  mount Security::Engine => '/security'
end
