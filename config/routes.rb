Rails.application.routes.draw do
  
  root 'dashboard#homepage'
  
  get '/login/clothier',          to: 'login#clothier_login'
  get '/login/admin',             to: 'login#admin_login'
  get '/login/recovery',          to: 'login#recovery'
  get '/login/recovery/:type',    to: 'login#recovery'
  get '/login/reset',             to: 'login#reset'
  get '/logout',                  to: 'login#logout'
  get '/clothier/modify',         to: 'clothiers#modify'
  get '/clothier/list',           to: 'clothiers#list'
  get '/clothier/credit/:id',     to: 'clothiers#orderAdd'
  get '/shopify',                 to: 'clothiers#checkShopify', :defaults => { :format => 'json' }
  get '/admin/modify',            to: 'admin#modify'
  get '/orders',                  to: 'clothiers#orders'
  get '/customers',               to: 'dashboard#homepage'
  
  #Commissions Reports
  get '/commissions/xlsx/:id',     to: 'clothiers#generate_commissions', :defaults => {:format => 'xlsx'}  
  get '/commissions/:id',          to: 'clothiers#commissions'
  get '/commissions/:id/:time',    to: 'clothiers#commissions'
  post '/clothier/credit/:id',     to: 'clothiers#orderAdd'
  post '/commission/remove',       to: 'clothiers#orderRemove'
  
  
  
  post '/login/clothier',         to: 'login#clothier_login'
  post '/login/admin',            to: 'login#admin_login'
  post '/login/recovery/:type',   to: 'login#recovery'
  post '/login/reset',            to: 'login#reset'

  post '/clothier/toggle',        to: 'clothiers#toggle', :defaults => { :format => 'json' }
  post '/clothier/add',           to: 'clothiers#add', :defaults => { :format => 'json' }
  post '/admin/add',              to: 'admin#add', :defaults => { :format => 'json' }
  post '/admin/remove',           to: 'admin#remove', :defaults => { :format => 'json' }
  
  #Shopify Customer Routes
  
  get '/admin/customer_passwords', to: 'admin#customer_passwords'
  post '/admin/customer_passwords', to: 'admin#customer_passwords'
  
  #API Routes
  
  
  get '/order/:order',              to: 'clothiers#generate_excel', :defaults => {:format => 'xlsx'}
  get '/api/test/:order',           to: 'api#generate_excel', :defaults => {:format => 'xlsx'}
  get '/api/test',                  to: 'api#test_it'
  get '/api',                       to: 'api#index'
  get '/api/codes',                 to: 'api#line_codes'
  get '/api/csv',                   to: 'api#csv_codes'
  get '/api/csv/:garment',          to: 'api#new_csv'
  get '/api/codes/:garment',        to: 'api#new_code'
  get '/api/csv/remove/:garment/:id', to: 'api#remove_code'
  get '/api/download',              to: 'api#download_csv'
  post '/api/csv/:garment',         to: 'api#csv_upload', :defaults => { :format => 'json' }
  post '/api/create',               to: 'api#add_code', :defaults => { :format => 'json' }
  post '/api/update/:id',           to: 'api#update_code', :defaults => { :format => 'json' }
  post '/webhook',                  to: 'api#receive_webhook', :defaults => { :format => 'json' }

  
end
