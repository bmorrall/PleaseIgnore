Security::Engine.routes.draw do
  resource :csp_report, only: :create
  resource :hpkp_report, only: :create
end
