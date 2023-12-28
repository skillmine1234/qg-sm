Rails.application.routes.draw do
  resources :sm_banks do
    member do
      get :resend_notification
    end
  end
  
  resources :sm_bank_accounts
  resources :sm_unapproved_records

  resources :sm_payments, only: [:index, :show] do
    collection do
      get :index
      get :index
    end
    
    member do
      get :steps
    end
  end
  
  get '/sm_banks/:id/audit_logs' => 'sm_banks#audit_logs'
  get '/sm_bank_accounts/:id/audit_logs' => 'sm_bank_accounts#audit_logs'
  get '/sm_banks/:id/approve' => "sm_banks#approve"
  get '/sm_bank_accounts/:id/approve' => 'sm_bank_accounts#approve'
  
  # operation_routes_for 'sm_payments'
end
